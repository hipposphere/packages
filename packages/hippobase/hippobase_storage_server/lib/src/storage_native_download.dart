import 'package:dart_edge_native_bridge/dart_edge_native_bridge.dart';
import 'package:hippobase_storage_models/hippobase_storage_models.dart';

/// A single-owner native object body and its storage metadata.
final class StorageNativeDownloadStream {
  const StorageNativeDownloadStream({required this.body, required this.metadata});

  final NativeByteStreamHandle body;
  final StorageObjectMetadata metadata;

  /// Cancels and releases the native body when it was not adopted by a native
  /// consumer.
  Future<void> close() => body.close();
}

/// Metadata for an object downloaded directly into a native-managed file.
final class StorageNativeFileDownload {
  const StorageNativeFileDownload({required this.outputPath, required this.metadata});

  final String outputPath;
  final StorageObjectMetadata metadata;
}
