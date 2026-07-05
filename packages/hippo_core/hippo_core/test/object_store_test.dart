import 'dart:convert';
import 'dart:typed_data';

import 'package:hippo_core/hippo_core.dart';
import 'package:test/test.dart';

void main() {
  test('ObjectStoreKey validates and encodes path segments', () {
    final key = ObjectStoreKey(['workspace one', 'chat:1']);

    expect(key.path, 'workspace one/chat:1');
    expect(key.encodedPath, 'workspace%20one/chat%3A1');
    expect(ObjectStoreKey.fromEncodedPath(key.encodedPath), key);
    expect(() => ObjectStoreKey(['..']), throwsArgumentError);
    expect(() => ObjectStoreKey(['folder/item']), throwsArgumentError);
  });

  test('JsonObjectStore stores JSON documents in a binary store', () async {
    final binaryStore = MemoryBinaryObjectStore();
    final jsonStore = JsonObjectStore(binaryStore);
    final key = ObjectStoreKey(['scope', 'index.json']);

    await jsonStore.writeJson(key, {
      'version': 1,
      'items': ['a', 'b'],
    });

    expect(await jsonStore.readJsonMap(key), {
      'version': 1,
      'items': ['a', 'b'],
    });
  });

  test('MemoryBinaryObjectStore lists and deletes by prefix', () async {
    final store = MemoryBinaryObjectStore();
    final prefix = ObjectStoreKey(['scope']);

    await store.writeBytes(prefix.child('a'), Uint8List.fromList([1]));
    await store.writeBytes(prefix.resolve(['nested', 'b']), Uint8List.fromList([2]));
    await store.writeBytes(ObjectStoreKey(['other', 'c']), Uint8List.fromList([3]));

    expect((await store.list(prefix)).map((entry) => entry.key.path), [
      'scope/a',
      'scope/nested/b',
    ]);

    await store.deleteTree(prefix);

    expect(await store.exists(prefix.child('a')), isFalse);
    expect(await store.exists(ObjectStoreKey(['other', 'c'])), isTrue);
  });

  test('EncryptedObjectStore encrypts payloads and authenticates object keys', () async {
    final inner = MemoryBinaryObjectStore();
    final encryptedStore = EncryptedObjectStore(
      inner: inner,
      keyring: StaticObjectStoreKeyring(ObjectStoreSecretKey.random(id: 'test-key')),
    );
    final key = ObjectStoreKey(['scope', 'chat.json']);
    final payload = Uint8List.fromList(utf8.encode('very secret text'));

    await encryptedStore.writeBytes(key, payload);

    final storedBytes = await inner.readBytes(key);
    expect(storedBytes, isNotNull);
    expect(utf8.decode(storedBytes!), isNot(contains('very secret text')));
    expect(await encryptedStore.readBytes(key), payload);

    final wrongKey = ObjectStoreKey(['scope', 'other-chat.json']);
    await inner.writeBytes(wrongKey, storedBytes);

    expect(encryptedStore.readBytes(wrongKey), throwsA(anything));
  });
}
