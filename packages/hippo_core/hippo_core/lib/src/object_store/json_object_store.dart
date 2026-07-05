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

import 'binary_object_store.dart';
import 'object_store_key.dart';

final class JsonObjectStore {
  const JsonObjectStore(this.store);

  final BinaryObjectStore store;

  Future<Object?> readJson(ObjectStoreKey key) async {
    final bytes = await store.readBytes(key);
    if (bytes == null) {
      return null;
    }
    return jsonDecode(utf8.decode(bytes));
  }

  Future<Map<String, Object?>?> readJsonMap(ObjectStoreKey key) async {
    final value = await readJson(key);
    if (value is! Map) {
      return null;
    }
    return Map<String, Object?>.from(value);
  }

  Future<List<Object?>?> readJsonList(ObjectStoreKey key) async {
    final value = await readJson(key);
    if (value is! List) {
      return null;
    }
    return List<Object?>.from(value);
  }

  Future<void> writeJson(ObjectStoreKey key, Object? value) {
    return store.writeBytes(key, Uint8List.fromList(utf8.encode(jsonEncode(value))));
  }

  Future<void> delete(ObjectStoreKey key) {
    return store.delete(key);
  }

  Future<void> deleteTree(ObjectStoreKey prefix) {
    return store.deleteTree(prefix);
  }
}
