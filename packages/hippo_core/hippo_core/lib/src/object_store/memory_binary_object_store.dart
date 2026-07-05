/*
// ---------------------------------------------------------------------------
// Copyright (c) 2025 HippoSphere UG (haftungsbeschränkt). All rights reserved.
// Use, copying, modification, or distribution of this software is prohibited
// without express written permission from Hipposphere UG.
//
// SPDX-License-Identifier: LicenseRef-Hipposphere-Proprietary
// ---------------------------------------------------------------------------
*/
import 'dart:typed_data';

import 'binary_object_store.dart';
import 'object_store_key.dart';

final class MemoryBinaryObjectStore implements BinaryObjectStore {
  final Map<ObjectStoreKey, Uint8List> _data = <ObjectStoreKey, Uint8List>{};
  final Map<ObjectStoreKey, DateTime> _modifiedAt = <ObjectStoreKey, DateTime>{};

  @override
  Future<bool> exists(ObjectStoreKey key) async {
    return _data.containsKey(key);
  }

  @override
  Future<Uint8List?> readBytes(ObjectStoreKey key) async {
    final bytes = _data[key];
    if (bytes == null) {
      return null;
    }
    return Uint8List.fromList(bytes);
  }

  @override
  Future<void> writeBytes(ObjectStoreKey key, Uint8List bytes) async {
    if (key.isRoot) {
      throw ArgumentError.value(key, 'key', 'Cannot write bytes to the object store root.');
    }
    _data[key] = Uint8List.fromList(bytes);
    _modifiedAt[key] = DateTime.now();
  }

  @override
  Future<void> delete(ObjectStoreKey key) async {
    _data.remove(key);
    _modifiedAt.remove(key);
  }

  @override
  Future<List<ObjectStoreEntry>> list(ObjectStoreKey prefix) async {
    final entries = <ObjectStoreEntry>[];
    for (final entry in _data.entries) {
      if (!prefix.isPrefixOf(entry.key)) {
        continue;
      }
      entries.add(
        ObjectStoreEntry(
          key: entry.key,
          size: entry.value.length,
          modifiedAt: _modifiedAt[entry.key],
        ),
      );
    }
    entries.sort((a, b) => a.key.encodedPath.compareTo(b.key.encodedPath));
    return entries;
  }

  @override
  Future<void> deleteTree(ObjectStoreKey prefix) async {
    final keys = _data.keys.where(prefix.isPrefixOf).toList(growable: false);
    for (final key in keys) {
      _data.remove(key);
      _modifiedAt.remove(key);
    }
  }
}
