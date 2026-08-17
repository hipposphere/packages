import 'package:dart_edge_native_bridge/dart_edge_native_bridge.dart';
import 'package:hippobase_storage_models/hippobase_storage_models.dart';

import 'storage_native_download.dart';

/// Optional capability for providers that can transfer an object body to
/// another native component without routing its chunks through Dart.
abstract interface class NativeStreamingStorageProvider {
  Future<StorageNativeDownloadStream> downloadNativeStream(String key);
}

/// Optional capability for providers that can natively stream one byte range.
abstract interface class NativeRangedStreamingStorageProvider {
  Future<StorageNativeDownloadStream> downloadNativeRangeStream(
    String key,
    StorageByteRange range,
  );
}

/// Optional capability for providers that can write an object directly to a
/// native-managed file without materializing its bytes in Dart.
abstract interface class NativeFileStorageProvider {
  Future<StorageNativeFileDownload> downloadToNativeFile(
    String key,
    String outputPath,
  );
}

/// Optional capability for providers that can consume a single-owner native
/// byte stream without materializing its chunks in Dart.
abstract interface class NativeStreamingUploadStorageProvider {
  Future<void> uploadNativeStream(
    String key,
    NativeByteStreamHandle body, {
    required int contentLength,
    StorageWriteOptions options = const StorageWriteOptions(),
  });
}
