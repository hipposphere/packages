/*
// ---------------------------------------------------------------------------
// Copyright (c) 2025 HippoSphere UG (haftungsbeschränkt). All rights reserved.
// Use, copying, modification, or distribution of this software is prohibited
// without express written permission from Hipposphere UG.
//
// SPDX-License-Identifier: LicenseRef-Hipposphere-Proprietary
// ---------------------------------------------------------------------------
*/
import 'dart:convert';
import 'dart:typed_data';

import 'package:cryptography/cryptography.dart';

import 'binary_object_store.dart';
import 'object_store_key.dart';
import 'object_store_keyring.dart';

const _encryptedObjectStoreMagic = 'hippo-object-store-encrypted';
const _encryptedObjectStoreVersion = 1;
const _encryptedObjectStoreAlgorithm = 'aes-256-gcm';

final class EncryptedObjectStore implements BinaryObjectStore {
  EncryptedObjectStore({required this.inner, required this.keyring});

  final BinaryObjectStore inner;
  final ObjectStoreKeyring keyring;
  final AesGcm _algorithm = AesGcm.with256bits();

  @override
  Future<bool> exists(ObjectStoreKey key) {
    return inner.exists(key);
  }

  @override
  Future<Uint8List?> readBytes(ObjectStoreKey key) async {
    final encryptedBytes = await inner.readBytes(key);
    if (encryptedBytes == null) {
      return null;
    }

    final envelope = _EncryptedObjectEnvelope.fromJson(
      Map<String, Object?>.from(jsonDecode(utf8.decode(encryptedBytes)) as Map),
    );
    final secretKey = await keyring.keyForId(envelope.keyId);
    if (secretKey == null) {
      throw StateError('No object store encryption key available for key id "${envelope.keyId}".');
    }

    final clearBytes = await _algorithm.decrypt(
      SecretBox(envelope.cipherText, nonce: envelope.nonce, mac: Mac(envelope.mac)),
      secretKey: SecretKey(secretKey.bytes),
      aad: _additionalAuthenticatedData(key),
    );
    return Uint8List.fromList(clearBytes);
  }

  @override
  Future<void> writeBytes(ObjectStoreKey key, Uint8List bytes) async {
    final secretKey = await keyring.currentKey();
    final nonce = _algorithm.newNonce();
    final secretBox = await _algorithm.encrypt(
      bytes,
      secretKey: SecretKey(secretKey.bytes),
      nonce: nonce,
      aad: _additionalAuthenticatedData(key),
    );
    final envelope = _EncryptedObjectEnvelope(
      keyId: secretKey.id,
      nonce: secretBox.nonce,
      mac: secretBox.mac.bytes,
      cipherText: secretBox.cipherText,
    );
    await inner.writeBytes(key, Uint8List.fromList(utf8.encode(jsonEncode(envelope.toJson()))));
  }

  @override
  Future<void> delete(ObjectStoreKey key) {
    return inner.delete(key);
  }

  @override
  Future<List<ObjectStoreEntry>> list(ObjectStoreKey prefix) {
    return inner.list(prefix);
  }

  @override
  Future<void> deleteTree(ObjectStoreKey prefix) {
    return inner.deleteTree(prefix);
  }

  List<int> _additionalAuthenticatedData(ObjectStoreKey key) {
    return utf8.encode(
      '$_encryptedObjectStoreMagic.v$_encryptedObjectStoreVersion:${key.encodedPath}',
    );
  }
}

final class _EncryptedObjectEnvelope {
  const _EncryptedObjectEnvelope({
    required this.keyId,
    required this.nonce,
    required this.mac,
    required this.cipherText,
  });

  factory _EncryptedObjectEnvelope.fromJson(Map<String, Object?> json) {
    final magic = json['magic'];
    final version = json['version'];
    final algorithm = json['algorithm'];
    if (magic != _encryptedObjectStoreMagic ||
        version != _encryptedObjectStoreVersion ||
        algorithm != _encryptedObjectStoreAlgorithm) {
      throw const FormatException('Unsupported encrypted object store payload.');
    }

    return _EncryptedObjectEnvelope(
      keyId: _readString(json['keyId'], 'keyId'),
      nonce: base64Decode(_readString(json['nonce'], 'nonce')),
      mac: base64Decode(_readString(json['mac'], 'mac')),
      cipherText: base64Decode(_readString(json['cipherText'], 'cipherText')),
    );
  }

  final String keyId;
  final List<int> nonce;
  final List<int> mac;
  final List<int> cipherText;

  Map<String, Object?> toJson() {
    return {
      'magic': _encryptedObjectStoreMagic,
      'version': _encryptedObjectStoreVersion,
      'algorithm': _encryptedObjectStoreAlgorithm,
      'keyId': keyId,
      'nonce': base64Encode(nonce),
      'mac': base64Encode(mac),
      'cipherText': base64Encode(cipherText),
    };
  }

  static String _readString(Object? value, String field) {
    if (value is String && value.isNotEmpty) {
      return value;
    }
    throw FormatException('Encrypted object store payload is missing "$field".');
  }
}
