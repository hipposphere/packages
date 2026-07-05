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

import 'package:hippo_core/hippo_core.dart';

final class SecureKeyValueObjectStoreKeyring implements ObjectStoreKeyring {
  const SecureKeyValueObjectStoreKeyring({
    required this.keyValueStore,
    required this.storeKey,
    this.keyId = 'current',
  });

  final KeyValueStore keyValueStore;
  final String storeKey;
  final String keyId;

  @override
  Future<ObjectStoreSecretKey> currentKey() async {
    final storedValue = await keyValueStore.getString(storeKey);
    if (storedValue != null && storedValue.trim().isNotEmpty) {
      return ObjectStoreSecretKey(id: keyId, bytes: base64Decode(storedValue));
    }

    final key = ObjectStoreSecretKey.random(id: keyId);
    await keyValueStore.setString(storeKey, base64Encode(key.bytes));
    return key;
  }

  @override
  Future<ObjectStoreSecretKey?> keyForId(String keyId) async {
    if (keyId != this.keyId) {
      return null;
    }
    return currentKey();
  }
}
