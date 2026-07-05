import 'dart:typed_data';

import 'package:hippobase_storage_models/hippobase_storage_models.dart';

import 'key_validation.dart';
import 'storage_provider.dart';

/// Facade for storage operations that keeps provider details out of callers.
final class StorageClient {
  const StorageClient({required this.provider});

  final StorageProvider provider;

  Future<void> close() {
    return provider.close();
  }

  Future<void> delete(String key) {
    validateStorageKey(key);
    return provider.delete(key);
  }

  Future<StorageObject> download(String key) {
    validateStorageKey(key);
    return provider.download(key);
  }

  Future<bool> exists(String key) {
    validateStorageKey(key);
    return provider.exists(key);
  }

  Future<StorageObjectMetadata> getMetadata(String key) {
    validateStorageKey(key);
    return provider.getMetadata(key);
  }

  Future<void> upload(
    String key,
    Uint8List bytes, {
    StorageWriteOptions options = const StorageWriteOptions(),
  }) {
    validateStorageKey(key);
    return provider.upload(key, bytes, options: options);
  }
}
