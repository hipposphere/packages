import 'storage_native_download.dart';

/// Optional capability for providers that can transfer an object body to
/// another native component without routing its chunks through Dart.
abstract interface class NativeStreamingStorageProvider {
  Future<StorageNativeDownloadStream> downloadNativeStream(String key);
}

/// Optional capability for providers that can write an object directly to a
/// native-managed file without materializing its bytes in Dart.
abstract interface class NativeFileStorageProvider {
  Future<StorageNativeFileDownload> downloadToNativeFile(String key, String outputPath);
}
