/// Metadata associated with a stored object.
final class StorageObjectMetadata {
  const StorageObjectMetadata({
    this.contentLength,
    this.versionId,
    this.eTag,
    this.contentType,
    this.cacheControl,
    this.contentDisposition,
    this.contentEncoding,
    this.contentLanguage,
    this.metadata = const <String, String>{},
  });

  /// Number of bytes stored for the object, when known.
  final int? contentLength;

  final String? versionId;
  final String? eTag;
  final String? contentType;
  final String? cacheControl;
  final String? contentDisposition;
  final String? contentEncoding;
  final String? contentLanguage;

  /// Provider-specific custom metadata.
  final Map<String, String> metadata;

  StorageObjectMetadata copyWith({
    int? contentLength,
    String? versionId,
    String? eTag,
    String? contentType,
    String? cacheControl,
    String? contentDisposition,
    String? contentEncoding,
    String? contentLanguage,
    Map<String, String>? metadata,
  }) {
    return StorageObjectMetadata(
      contentLength: contentLength ?? this.contentLength,
      versionId: versionId ?? this.versionId,
      eTag: eTag ?? this.eTag,
      contentType: contentType ?? this.contentType,
      cacheControl: cacheControl ?? this.cacheControl,
      contentDisposition: contentDisposition ?? this.contentDisposition,
      contentEncoding: contentEncoding ?? this.contentEncoding,
      contentLanguage: contentLanguage ?? this.contentLanguage,
      metadata: metadata ?? this.metadata,
    );
  }
}
