import 'package:dbus/dbus.dart';

const systemdBusName = 'org.freedesktop.systemd1';
const systemdManagerInterface = 'org.freedesktop.systemd1.Manager';
const systemdUnitInterface = 'org.freedesktop.systemd1.Unit';
final systemdManagerPath = DBusObjectPath('/org/freedesktop/systemd1');

abstract interface class SystemdBus {
  Future<List<DBusValue>> call({
    required DBusObjectPath path,
    required String interface,
    required String method,
    Iterable<DBusValue> values = const [],
    DBusSignature? replySignature,
    bool allowInteractiveAuthorization = false,
  });

  Future<Map<String, DBusValue>> getAllProperties({
    required DBusObjectPath path,
    required String interface,
  });

  Stream<DBusSignal> signals({
    DBusObjectPath? path,
    DBusObjectPath? pathNamespace,
    required String interface,
    required String name,
    DBusSignature? signature,
  });

  Future<void> close();
}

final class DBusSystemdBus implements SystemdBus {
  DBusSystemdBus(this._client);

  factory DBusSystemdBus.system() => DBusSystemdBus(DBusClient.system());
  factory DBusSystemdBus.session() => DBusSystemdBus(DBusClient.session());

  final DBusClient _client;

  @override
  Future<List<DBusValue>> call({
    required DBusObjectPath path,
    required String interface,
    required String method,
    Iterable<DBusValue> values = const [],
    DBusSignature? replySignature,
    bool allowInteractiveAuthorization = false,
  }) async {
    final response = await _client.callMethod(
      destination: systemdBusName,
      path: path,
      interface: interface,
      name: method,
      values: values,
      replySignature: replySignature,
      allowInteractiveAuthorization: allowInteractiveAuthorization,
    );
    return response.returnValues;
  }

  @override
  Future<Map<String, DBusValue>> getAllProperties({
    required DBusObjectPath path,
    required String interface,
  }) => DBusRemoteObject(_client, name: systemdBusName, path: path).getAllProperties(interface);

  @override
  Stream<DBusSignal> signals({
    DBusObjectPath? path,
    DBusObjectPath? pathNamespace,
    required String interface,
    required String name,
    DBusSignature? signature,
  }) => DBusSignalStream(
    _client,
    sender: systemdBusName,
    path: path,
    pathNamespace: pathNamespace,
    interface: interface,
    name: name,
    signature: signature,
  );

  @override
  Future<void> close() => _client.close();
}
