import 'dart:async';

import 'package:dbus/dbus.dart';
import 'package:systemd_client/systemd_client.dart';
import 'package:test/test.dart';

void main() {
  test('discovers loaded units and installed unit files', () async {
    final bus = FakeSystemdBus()
      ..replies['ListUnits'] = [
        DBusArray(DBusSignature('(ssssssouso)'), [
          DBusStruct([
            DBusString('dicto.service'),
            DBusString('Dicto'),
            DBusString('loaded'),
            DBusString('active'),
            DBusString('running'),
            DBusString(''),
            DBusObjectPath('/unit/dicto'),
            DBusUint32(0),
            DBusString(''),
            DBusObjectPath('/'),
          ]),
        ]),
      ]
      ..replies['ListUnitFiles'] = [
        DBusArray(DBusSignature('(ss)'), [
          DBusStruct([DBusString('/etc/systemd/system/dicto.service'), DBusString('enabled')]),
        ]),
      ];
    final client = SystemdClient(bus);

    final units = await client.listUnits();
    final files = await client.listUnitFiles();

    expect(units.single.name, 'dicto.service');
    expect(units.single.activeState, 'active');
    expect(files.single.state, 'enabled');
  });

  test('inspects generic and type-specific properties', () async {
    final bus = FakeSystemdBus()
      ..replies['GetUnit'] = [DBusObjectPath('/unit/dicto')]
      ..properties[systemdUnitInterface] = {'ActiveState': DBusString('active')}
      ..properties['org.freedesktop.systemd1.Service'] = {'MainPID': DBusUint32(42)};
    final details = await SystemdClient(bus).inspectUnit('dicto.service');

    expect(details.unitProperties['ActiveState'], 'active');
    expect(details.typeProperties['MainPID'], 42);
  });

  test('returns a typed lifecycle job and completes on JobRemoved', () async {
    final bus = FakeSystemdBus()
      ..replies['Subscribe'] = const []
      ..replies['RestartUnit'] = [DBusObjectPath('/job/7')];
    final client = SystemdClient(bus);

    final job = await client.restartUnit('dicto.service');
    bus.emit(
      DBusSignal(
        sender: systemdBusName,
        path: systemdManagerPath,
        interface: systemdManagerInterface,
        name: 'JobRemoved',
        values: [
          DBusUint32(7),
          DBusObjectPath('/job/7'),
          DBusString('dicto.service'),
          DBusString('done'),
        ],
      ),
    );

    final result = await job.completed;
    expect(result.id, 7);
    expect(result.succeeded, isTrue);
    expect(bus.calls.last.allowInteractiveAuthorization, isTrue);
  });

  test('streams unit and property changes', () async {
    final bus = FakeSystemdBus()
      ..replies['Subscribe'] = const []
      ..replies['GetUnit'] = [DBusObjectPath('/unit/dicto')];
    final client = SystemdClient(bus);
    final unitEvent = client.unitEvents().first;
    final propertyEvent = client.propertyChanges('dicto.service').first;
    await Future<void>.delayed(Duration.zero);

    bus.emit(
      DBusSignal(
        sender: systemdBusName,
        path: systemdManagerPath,
        interface: systemdManagerInterface,
        name: 'UnitNew',
        values: [DBusString('dicto.service'), DBusObjectPath('/unit/dicto')],
      ),
    );
    bus.emit(
      DBusSignal(
        sender: systemdBusName,
        path: DBusObjectPath('/unit/dicto'),
        interface: 'org.freedesktop.DBus.Properties',
        name: 'PropertiesChanged',
        values: [
          DBusString(systemdUnitInterface),
          DBusDict.stringVariant({'ActiveState': DBusString('failed')}),
          DBusArray.string(['SubState']),
        ],
      ),
    );

    expect((await unitEvent).type, SystemdUnitEventType.added);
    final change = await propertyEvent;
    expect(change.changedProperties['ActiveState'], 'failed');
    expect(change.invalidatedProperties, ['SubState']);
  });
}

final class FakeCall {
  const FakeCall(this.method, this.allowInteractiveAuthorization);
  final String method;
  final bool allowInteractiveAuthorization;
}

final class FakeSystemdBus implements SystemdBus {
  final Map<String, List<DBusValue>> replies = {};
  final Map<String, Map<String, DBusValue>> properties = {};
  final List<FakeCall> calls = [];
  final _signals = StreamController<DBusSignal>.broadcast(sync: true);

  void emit(DBusSignal signal) => _signals.add(signal);

  @override
  Future<List<DBusValue>> call({
    required DBusObjectPath path,
    required String interface,
    required String method,
    Iterable<DBusValue> values = const [],
    DBusSignature? replySignature,
    bool allowInteractiveAuthorization = false,
  }) async {
    calls.add(FakeCall(method, allowInteractiveAuthorization));
    return replies[method] ?? const [];
  }

  @override
  Future<Map<String, DBusValue>> getAllProperties({
    required DBusObjectPath path,
    required String interface,
  }) async => properties[interface] ?? const {};

  @override
  Stream<DBusSignal> signals({
    DBusObjectPath? path,
    DBusObjectPath? pathNamespace,
    required String interface,
    required String name,
    DBusSignature? signature,
  }) => _signals.stream.where(
    (signal) =>
        signal.interface == interface &&
        signal.name == name &&
        (path == null || signal.path == path),
  );

  @override
  Future<void> close() async => _signals.close();
}
