/*
// ---------------------------------------------------------------------------
// Copyright (c) 2025 HippoSphere UG (haftungsbeschränkt). All rights reserved.
// Use, copying, modification, or distribution of this software is prohibited
// without express written permission from Hipposphere UG.
//
// SPDX-License-Identifier: LicenseRef-Hipposphere-Proprietary
// ---------------------------------------------------------------------------
*/
import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:hippo_core/hippo_core.dart';
import 'package:path_provider/path_provider.dart';

typedef ObjectStoreRootPathResolver = Future<String> Function();

final class ApplicationSupportObjectStore implements BinaryObjectStore {
  ApplicationSupportObjectStore({
    required this.namespace,
    this.rootDirectoryPath,
    this.rootPathResolver,
  }) {
    _validateNamespace(namespace);
  }

  final String namespace;
  final String? rootDirectoryPath;
  final ObjectStoreRootPathResolver? rootPathResolver;
  final Map<String, Future<void>> _writeLocks = <String, Future<void>>{};
  final Random _random = Random.secure();

  @override
  Future<bool> exists(ObjectStoreKey key) async {
    if (key.isRoot) {
      return false;
    }
    return _fileForKey(key).then((file) => file.exists());
  }

  @override
  Future<Uint8List?> readBytes(ObjectStoreKey key) async {
    if (key.isRoot) {
      return null;
    }
    final file = await _fileForKey(key);
    if (!await file.exists()) {
      return null;
    }
    return file.readAsBytes();
  }

  @override
  Future<void> writeBytes(ObjectStoreKey key, Uint8List bytes) {
    if (key.isRoot) {
      throw ArgumentError.value(key, 'key', 'Cannot write bytes to the object store root.');
    }
    return _runLocked(key.encodedPath, () async {
      final file = await _fileForKey(key);
      await file.parent.create(recursive: true);
      final tempFile = File(
        '${file.path}.tmp-${DateTime.now().microsecondsSinceEpoch}-${_random.nextInt(1 << 32)}',
      );
      try {
        await tempFile.writeAsBytes(bytes, flush: true);
        if (await file.exists()) {
          await file.delete();
        }
        await tempFile.rename(file.path);
      } catch (_) {
        await _safeDelete(tempFile);
        rethrow;
      }
    });
  }

  @override
  Future<void> delete(ObjectStoreKey key) async {
    if (key.isRoot) {
      return;
    }
    final file = await _fileForKey(key);
    await _safeDelete(file);
    await _deleteEmptyParents(file.parent);
  }

  @override
  Future<List<ObjectStoreEntry>> list(ObjectStoreKey prefix) async {
    final root = await _rootDirectory();
    final entries = <ObjectStoreEntry>[];

    if (!prefix.isRoot) {
      final exactFile = await _fileForKey(prefix);
      if (await exactFile.exists()) {
        entries.add(await _entryForFile(root, exactFile));
      }
    }

    final directory = prefix.isRoot ? root : Directory((await _fileForKey(prefix)).path);
    if (await directory.exists()) {
      await for (final entity in directory.list(recursive: true, followLinks: false)) {
        if (entity is! File || _isTemporaryFile(entity)) {
          continue;
        }
        entries.add(await _entryForFile(root, entity));
      }
    }

    entries.sort((a, b) => a.key.encodedPath.compareTo(b.key.encodedPath));
    return entries;
  }

  @override
  Future<void> deleteTree(ObjectStoreKey prefix) async {
    final root = await _rootDirectory();
    if (prefix.isRoot) {
      if (await root.exists()) {
        await root.delete(recursive: true);
      }
      return;
    }

    final file = await _fileForKey(prefix);
    await _safeDelete(file);

    final directory = Directory(file.path);
    if (await directory.exists()) {
      await directory.delete(recursive: true);
    }
    await _deleteEmptyParents(file.parent);
  }

  Future<Directory> _rootDirectory() async {
    final explicitPath = rootDirectoryPath;
    if (explicitPath != null) {
      return Directory(explicitPath);
    }

    final resolver = rootPathResolver;
    if (resolver != null) {
      return Directory(await resolver());
    }

    final applicationSupportDirectory = await getApplicationSupportDirectory();
    return Directory(
      '${applicationSupportDirectory.path}${Platform.pathSeparator}hippo_object_store${Platform.pathSeparator}$namespace',
    );
  }

  Future<File> _fileForKey(ObjectStoreKey key) async {
    final root = await _rootDirectory();
    return File([root.path, ...key.encodedSegments].join(Platform.pathSeparator));
  }

  Future<ObjectStoreEntry> _entryForFile(Directory root, File file) async {
    final stat = await file.stat();
    return ObjectStoreEntry(
      key: _keyForFile(root, file),
      size: stat.size,
      modifiedAt: stat.modified,
    );
  }

  ObjectStoreKey _keyForFile(Directory root, File file) {
    final relativePath = file.path
        .substring(root.path.length)
        .replaceFirst(RegExp('^${RegExp.escape(Platform.pathSeparator)}'), '');
    return ObjectStoreKey(relativePath.split(Platform.pathSeparator).map(Uri.decodeComponent));
  }

  bool _isTemporaryFile(File file) {
    final fileName = file.uri.pathSegments.isEmpty ? '' : file.uri.pathSegments.last;
    return fileName.contains('.tmp-');
  }

  Future<T> _runLocked<T>(String key, Future<T> Function() action) async {
    final previous = _writeLocks[key] ?? Future<void>.value();
    final release = Completer<void>();
    final next = previous.catchError((_) {}).then((_) => release.future);
    _writeLocks[key] = next;
    await previous.catchError((_) {});

    try {
      return await action();
    } finally {
      release.complete();
      if (identical(_writeLocks[key], next)) {
        _writeLocks.remove(key);
      }
    }
  }

  Future<void> _deleteEmptyParents(Directory directory) async {
    final root = await _rootDirectory();
    var current = directory;
    while (current.path.startsWith(root.path) && current.path != root.path) {
      if (!await current.exists()) {
        current = current.parent;
        continue;
      }
      final children = await current.list(followLinks: false).toList();
      if (children.isNotEmpty) {
        return;
      }
      await current.delete();
      current = current.parent;
    }
  }

  Future<void> _safeDelete(File file) async {
    try {
      if (await file.exists()) {
        await file.delete();
      }
    } catch (_) {}
  }

  void _validateNamespace(String namespace) {
    if (namespace.trim().isEmpty) {
      throw ArgumentError.value(namespace, 'namespace', 'Object store namespace cannot be empty.');
    }
    if (namespace.contains('/') || namespace.contains('\\') || namespace.contains('\x00')) {
      throw ArgumentError.value(
        namespace,
        'namespace',
        'Object store namespace cannot contain path separators or null bytes.',
      );
    }
  }
}
