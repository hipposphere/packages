import 'dart:async';

import 'package:dbus/dbus.dart';

import 'bus.dart';
import 'errors.dart';
import 'models.dart';

final class SystemdClient {
  SystemdClient(this._bus, {this.closeBus = false});

  factory SystemdClient.system() => SystemdClient(DBusSystemdBus.system(), closeBus: true);

  factory SystemdClient.session() => SystemdClient(DBusSystemdBus.session(), closeBus: true);

  final SystemdBus _bus;

  /// Whether [close] also closes the injected D-Bus connection.
  final bool closeBus;
  Future<void>? _initialization;
  bool _subscribed = false;
  bool _closed = false;

  Future<void> initialize() => _initialization ??= _subscribe();

  Future<void> _subscribe() async {
    await _callManager('Subscribe', replySignature: DBusSignature(''));
    _subscribed = true;
  }

  Future<List<SystemdUnit>> listUnits() async {
    final values = await _callManager('ListUnits', replySignature: DBusSignature('a(ssssssouso)'));
    return values.single.asArray().map(_parseUnit).toList(growable: false);
  }

  Future<List<SystemdUnitFile>> listUnitFiles() async {
    final values = await _callManager('ListUnitFiles', replySignature: DBusSignature('a(ss)'));
    return values.single
        .asArray()
        .map((value) {
          final fields = value.asStruct();
          return SystemdUnitFile(path: fields[0].asString(), state: fields[1].asString());
        })
        .toList(growable: false);
  }

  Future<DBusObjectPath> getUnitPath(String unitName) async {
    final values = await _callManager(
      'GetUnit',
      values: [DBusString(unitName)],
      replySignature: DBusSignature('o'),
    );
    return values.single.asObjectPath();
  }

  Future<SystemdUnitDetails> inspectUnit(String unitName, {String? typeInterface}) async {
    final path = await getUnitPath(unitName);
    final unitProperties = await _properties(path, systemdUnitInterface);
    final interface = typeInterface ?? _interfaceForUnit(unitName);
    final typeProperties = interface == null
        ? const <String, Object?>{}
        : await _properties(path, interface);
    return SystemdUnitDetails(
      name: unitName,
      objectPath: path,
      unitProperties: unitProperties,
      typeProperties: typeProperties,
    );
  }

  Future<SystemdJob> startUnit(String unitName, {SystemdJobMode mode = SystemdJobMode.replace}) =>
      _unitOperation('StartUnit', unitName, mode);

  Future<SystemdJob> stopUnit(String unitName, {SystemdJobMode mode = SystemdJobMode.replace}) =>
      _unitOperation('StopUnit', unitName, mode);

  Future<SystemdJob> restartUnit(String unitName, {SystemdJobMode mode = SystemdJobMode.replace}) =>
      _unitOperation('RestartUnit', unitName, mode);

  Future<SystemdJob> reloadUnit(String unitName, {SystemdJobMode mode = SystemdJobMode.replace}) =>
      _unitOperation('ReloadUnit', unitName, mode);

  Future<SystemdJob> reloadOrRestartUnit(
    String unitName, {
    SystemdJobMode mode = SystemdJobMode.replace,
  }) => _unitOperation('ReloadOrRestartUnit', unitName, mode);

  Future<void> reloadManager() async {
    await _callManager(
      'Reload',
      replySignature: DBusSignature(''),
      allowInteractiveAuthorization: true,
    );
  }

  Stream<SystemdUnitEvent> unitEvents() async* {
    await initialize();
    final controller = StreamController<SystemdUnitEvent>();
    final subscriptions = <StreamSubscription<DBusSignal>>[];
    subscriptions.add(
      _managerSignals('UnitNew', DBusSignature('so')).listen(
        (signal) => controller.add(_parseUnitEvent(signal, true)),
        onError: controller.addError,
      ),
    );
    subscriptions.add(
      _managerSignals('UnitRemoved', DBusSignature('so')).listen(
        (signal) => controller.add(_parseUnitEvent(signal, false)),
        onError: controller.addError,
      ),
    );
    controller.onCancel = () async {
      for (final subscription in subscriptions) {
        await subscription.cancel();
      }
    };
    yield* controller.stream;
  }

  Stream<SystemdJobResult> jobEvents() async* {
    await initialize();
    yield* _managerSignals('JobRemoved', DBusSignature('uoss')).map(_parseJobResult);
  }

  Stream<SystemdPropertyChange> propertyChanges(String unitName) async* {
    await initialize();
    final path = await getUnitPath(unitName);
    yield* _bus
        .signals(
          path: path,
          interface: 'org.freedesktop.DBus.Properties',
          name: 'PropertiesChanged',
          signature: DBusSignature('sa{sv}as'),
        )
        .map(_parsePropertyChange);
  }

  Future<SystemdJob> _unitOperation(String method, String unitName, SystemdJobMode mode) async {
    await initialize();
    final completer = Completer<SystemdJobResult>();
    final buffered = <SystemdJobResult>[];
    DBusObjectPath? expectedPath;
    late final StreamSubscription<DBusSignal> subscription;
    subscription = _managerSignals('JobRemoved', DBusSignature('uoss')).listen(
      (signal) {
        final event = _parseJobResult(signal);
        final path = expectedPath;
        if (path == null) {
          buffered.add(event);
        } else if (event.objectPath == path && !completer.isCompleted) {
          completer.complete(event);
          unawaited(subscription.cancel());
        }
      },
      onError: (Object error, StackTrace stackTrace) {
        if (!completer.isCompleted) completer.completeError(error, stackTrace);
      },
    );

    try {
      final values = await _callManager(
        method,
        values: [DBusString(unitName), DBusString(mode.value)],
        replySignature: DBusSignature('o'),
        allowInteractiveAuthorization: true,
      );
      expectedPath = values.single.asObjectPath();
      for (final event in buffered) {
        if (event.objectPath == expectedPath && !completer.isCompleted) {
          completer.complete(event);
          await subscription.cancel();
          break;
        }
      }
      return SystemdJob(objectPath: expectedPath, unitName: unitName, completed: completer.future);
    } catch (_) {
      await subscription.cancel();
      rethrow;
    }
  }

  Stream<DBusSignal> _managerSignals(String name, DBusSignature signature) => _bus.signals(
    path: systemdManagerPath,
    interface: systemdManagerInterface,
    name: name,
    signature: signature,
  );

  Future<List<DBusValue>> _callManager(
    String method, {
    Iterable<DBusValue> values = const [],
    DBusSignature? replySignature,
    bool allowInteractiveAuthorization = false,
  }) async {
    _ensureOpen();
    try {
      return await _bus.call(
        path: systemdManagerPath,
        interface: systemdManagerInterface,
        method: method,
        values: values,
        replySignature: replySignature,
        allowInteractiveAuthorization: allowInteractiveAuthorization,
      );
    } on DBusMethodResponseException catch (error) {
      final message = error.response.values.isEmpty
          ? null
          : error.response.values.first.toNative().toString();
      throw SystemdClientException(method: method, errorName: error.errorName, message: message);
    }
  }

  Future<Map<String, Object?>> _properties(DBusObjectPath path, String interface) async {
    _ensureOpen();
    final values = await _bus.getAllProperties(path: path, interface: interface);
    return values.map((key, value) => MapEntry(key, value.toNative()));
  }

  Future<void> close() async {
    if (_closed) return;
    if (_subscribed) {
      await _callManager('Unsubscribe', replySignature: DBusSignature(''));
    }
    _closed = true;
    if (closeBus) await _bus.close();
  }

  void _ensureOpen() {
    if (_closed) throw StateError('SystemdClient is closed.');
  }
}

SystemdUnit _parseUnit(DBusValue value) {
  final fields = value.asStruct();
  return SystemdUnit(
    name: fields[0].asString(),
    description: fields[1].asString(),
    loadState: fields[2].asString(),
    activeState: fields[3].asString(),
    subState: fields[4].asString(),
    followedUnit: fields[5].asString(),
    objectPath: fields[6].asObjectPath(),
    jobId: fields[7].asUint32(),
    jobType: fields[8].asString(),
    jobPath: fields[9].asObjectPath(),
  );
}

SystemdUnitEvent _parseUnitEvent(DBusSignal signal, bool added) => SystemdUnitEvent(
  type: added ? SystemdUnitEventType.added : SystemdUnitEventType.removed,
  name: signal.values[0].asString(),
  objectPath: signal.values[1].asObjectPath(),
);

SystemdJobResult _parseJobResult(DBusSignal signal) => SystemdJobResult(
  id: signal.values[0].asUint32(),
  objectPath: signal.values[1].asObjectPath(),
  unitName: signal.values[2].asString(),
  result: signal.values[3].asString(),
);

SystemdPropertyChange _parsePropertyChange(DBusSignal signal) => SystemdPropertyChange(
  objectPath: signal.path,
  interface: signal.values[0].asString(),
  changedProperties: signal.values[1].asStringVariantDict().map(
    (key, value) => MapEntry(key, value.toNative()),
  ),
  invalidatedProperties: signal.values[2].asStringArray().toList(),
);

String? _interfaceForUnit(String unitName) {
  final dot = unitName.lastIndexOf('.');
  if (dot < 0 || dot == unitName.length - 1) return null;
  final type = unitName.substring(dot + 1);
  return 'org.freedesktop.systemd1.${type[0].toUpperCase()}${type.substring(1)}';
}
