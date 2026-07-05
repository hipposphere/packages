import 'dart:typed_data';

import 'package:hippobase_storage_models/hippobase_storage_models.dart';

/// Backend contract implemented by concrete storage providers.
abstract interface class StorageProvider {
  Future<StorageObject> download(String key);

  Future<StorageObjectMetadata> getMetadata(String key);

  Future<void> upload(
    String key,
    Uint8List bytes, {
    StorageWriteOptions options = const StorageWriteOptions(),
  });

  Future<void> delete(String key);

  Future<bool> exists(String key);
}
