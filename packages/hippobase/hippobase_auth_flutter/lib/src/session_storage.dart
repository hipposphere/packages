import 'package:hippo_core/hippo_core.dart';

import 'session.dart';

abstract interface class HippobaseAuthSessionStorage {
  Future<HippobaseAuthSession?> read();

  Future<void> write(HippobaseAuthSession session);

  Future<void> clear();
}

final class HippobaseAuthKeyValueSessionStorage implements HippobaseAuthSessionStorage {
  HippobaseAuthKeyValueSessionStorage({required this.store, this.key = 'hippobase_auth_session'});

  final KeyValueStore store;
  final String key;

  @override
  Future<HippobaseAuthSession?> read() async {
    final value = await store.getString(key);
    if (value == null) return null;
    try {
      final session = HippobaseAuthSession.decode(value);
      if (!session.isExpired) return session;
    } on Object {
      // Invalid local state is discarded below.
    }
    await clear();
    return null;
  }

  @override
  Future<void> write(HippobaseAuthSession session) {
    return store.setString(key, session.encode());
  }

  @override
  Future<void> clear() => store.removeValue(key);
}

final class HippobaseAuthMemorySessionStorage implements HippobaseAuthSessionStorage {
  HippobaseAuthSession? value;

  @override
  Future<void> clear() async => value = null;

  @override
  Future<HippobaseAuthSession?> read() async {
    return value?.isExpired == true ? null : value;
  }

  @override
  Future<void> write(HippobaseAuthSession session) async => value = session;
}
