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

import 'object_store_key.dart';

abstract interface class BinaryObjectStore {
  Future<bool> exists(ObjectStoreKey key);

  Future<Uint8List?> readBytes(ObjectStoreKey key);

  Future<void> writeBytes(ObjectStoreKey key, Uint8List bytes);

  Future<void> delete(ObjectStoreKey key);

  Future<List<ObjectStoreEntry>> list(ObjectStoreKey prefix);

  Future<void> deleteTree(ObjectStoreKey prefix);
}

final class ObjectStoreEntry {
  const ObjectStoreEntry({required this.key, required this.size, required this.modifiedAt});

  final ObjectStoreKey key;
  final int size;
  final DateTime? modifiedAt;
}
