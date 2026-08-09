import 'dart:typed_data';

import 'package:hippobase_storage_models/hippobase_storage_models.dart';

import 'key_validation.dart';
import 'storage_provider.dart';
import 'storage_download_stream.dart';
import 'storage_native_download.dart';
import 'storage_native_provider.dart';

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

  /// Downloads an object as a demand-driven stream.
  Future<StorageDownloadStream> downloadStream(String key) {
    validateStorageKey(key);
    return provider.downloadStream(key);
  }

  /// Opens a single-owner native body when the provider supports native
  /// streaming, or returns `null` without starting a download otherwise.
  Future<StorageNativeDownloadStream?> downloadNativeStream(String key) {
    validateStorageKey(key);
    final provider = this.provider;
    if (provider case NativeStreamingStorageProvider nativeProvider) {
      return nativeProvider.downloadNativeStream(key);
    }
    return Future.value();
  }

  /// Downloads directly to [outputPath] when the provider supports native file
  /// transfer, or returns `null` without starting a download otherwise.
  Future<StorageNativeFileDownload?> downloadToNativeFile(String key, String outputPath) {
    validateStorageKey(key);
    if (outputPath.trim().isEmpty) {
      throw ArgumentError.value(outputPath, 'outputPath', 'Output path cannot be empty.');
    }
    final provider = this.provider;
    if (provider case NativeFileStorageProvider nativeProvider) {
      return nativeProvider.downloadToNativeFile(key, outputPath);
    }
    return Future.value();
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
