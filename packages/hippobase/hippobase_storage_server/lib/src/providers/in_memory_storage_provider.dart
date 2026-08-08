import 'dart:typed_data';

import 'package:hippobase_storage_models/hippobase_storage_models.dart';

import '../key_validation.dart';
import '../storage_provider.dart';
import '../storage_download_stream.dart';

/// In-memory storage provider for tests and ephemeral runtime state.
final class InMemoryStorageProvider implements StorageProvider {
  InMemoryStorageProvider({Map<String, StorageObject>? objects})
    : _objects = <String, StorageObject>{...?objects};

  final Map<String, StorageObject> _objects;

  @override
  Future<void> close() async {}

  @override
  Future<void> delete(String key) async {
    validateStorageKey(key);
    _objects.remove(key);
  }

  @override
  Future<StorageObject> download(String key) async {
    validateStorageKey(key);
    final object = _objects[key];
    if (object == null) {
      throw StateError('No object exists for key "$key".');
    }

    return StorageObject(bytes: Uint8List.fromList(object.bytes), metadata: object.metadata);
  }

  @override
  Future<StorageDownloadStream> downloadStream(String key) async {
    final object = await download(key);
    return StorageDownloadStream(metadata: object.metadata, body: Stream.value(object.bytes));
  }

  @override
  Future<bool> exists(String key) async {
    validateStorageKey(key);
    return _objects.containsKey(key);
  }

  @override
  Future<StorageObjectMetadata> getMetadata(String key) async {
    validateStorageKey(key);
    final object = _objects[key];
    if (object == null) {
      throw StateError('No object exists for key "$key".');
    }

    return object.metadata;
  }

  @override
  Future<void> upload(
    String key,
    Uint8List bytes, {
    StorageWriteOptions options = const StorageWriteOptions(),
  }) async {
    validateStorageKey(key);
    _objects[key] = StorageObject(
      bytes: Uint8List.fromList(bytes),
      metadata: options.toMetadata(contentLength: bytes.length),
    );
  }
}
