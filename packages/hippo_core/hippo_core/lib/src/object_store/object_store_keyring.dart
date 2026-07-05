/*
// ---------------------------------------------------------------------------
// Copyright (c) 2025 HippoSphere UG (haftungsbeschränkt). All rights reserved.
// Use, copying, modification, or distribution of this software is prohibited
// without express written permission from Hipposphere UG.
//
// SPDX-License-Identifier: LicenseRef-Hipposphere-Proprietary
// ---------------------------------------------------------------------------
*/
import 'dart:math';
import 'dart:typed_data';

const objectStoreAes256GcmKeyLength = 32;

abstract interface class ObjectStoreKeyring {
  Future<ObjectStoreSecretKey> currentKey();

  Future<ObjectStoreSecretKey?> keyForId(String keyId);
}

final class ObjectStoreSecretKey {
  ObjectStoreSecretKey({required this.id, required List<int> bytes})
    : _bytes = Uint8List.fromList(bytes) {
    if (id.trim().isEmpty) {
      throw ArgumentError.value(id, 'id', 'Object store secret key id cannot be empty.');
    }
    if (_bytes.length != objectStoreAes256GcmKeyLength) {
      throw ArgumentError.value(
        _bytes.length,
        'bytes',
        'Object store AES-256-GCM keys must be $objectStoreAes256GcmKeyLength bytes.',
      );
    }
  }

  factory ObjectStoreSecretKey.random({required String id}) {
    final random = Random.secure();
    return ObjectStoreSecretKey(
      id: id,
      bytes: List<int>.generate(objectStoreAes256GcmKeyLength, (_) => random.nextInt(256)),
    );
  }

  final String id;
  final Uint8List _bytes;

  Uint8List get bytes => Uint8List.fromList(_bytes);
}

final class StaticObjectStoreKeyring implements ObjectStoreKeyring {
  const StaticObjectStoreKeyring(this.key);

  final ObjectStoreSecretKey key;

  @override
  Future<ObjectStoreSecretKey> currentKey() async => key;

  @override
  Future<ObjectStoreSecretKey?> keyForId(String keyId) async => keyId == key.id ? key : null;
}
