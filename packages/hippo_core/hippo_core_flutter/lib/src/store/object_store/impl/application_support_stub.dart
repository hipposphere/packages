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

import 'package:hippo_core/hippo_core.dart';

typedef ObjectStoreRootPathResolver = Future<String> Function();

final class ApplicationSupportObjectStore implements BinaryObjectStore {
  ApplicationSupportObjectStore({
    required this.namespace,
    this.rootDirectoryPath,
    this.rootPathResolver,
  });

  final String namespace;
  final String? rootDirectoryPath;
  final ObjectStoreRootPathResolver? rootPathResolver;

  @override
  Future<bool> exists(ObjectStoreKey key) => throw _unsupported();

  @override
  Future<Uint8List?> readBytes(ObjectStoreKey key) => throw _unsupported();

  @override
  Future<void> writeBytes(ObjectStoreKey key, Uint8List bytes) => throw _unsupported();

  @override
  Future<void> delete(ObjectStoreKey key) => throw _unsupported();

  @override
  Future<List<ObjectStoreEntry>> list(ObjectStoreKey prefix) => throw _unsupported();

  @override
  Future<void> deleteTree(ObjectStoreKey prefix) => throw _unsupported();

  UnsupportedError _unsupported() {
    return UnsupportedError(
      'ApplicationSupportObjectStore is only available on dart:io platforms.',
    );
  }
}
