import 'storage_object_metadata.dart';

/// Options applied when writing an object to storage.
final class StorageWriteOptions {
  const StorageWriteOptions({
    this.contentType,
    this.cacheControl,
    this.contentDisposition,
    this.contentEncoding,
    this.contentLanguage,
    this.metadata = const <String, String>{},
  });

  final String? contentType;
  final String? cacheControl;
  final String? contentDisposition;
  final String? contentEncoding;
  final String? contentLanguage;

  /// Provider-specific custom metadata.
  final Map<String, String> metadata;

  StorageObjectMetadata toMetadata({int? contentLength}) {
    return StorageObjectMetadata(
      contentLength: contentLength,
      contentType: contentType,
      cacheControl: cacheControl,
      contentDisposition: contentDisposition,
      contentEncoding: contentEncoding,
      contentLanguage: contentLanguage,
      metadata: metadata,
    );
  }
}
