import 'dart:typed_data';

import 'package:dart_edge_core/dart_edge_core.dart';
import 'package:dart_edge_native_bridge/dart_edge_native_bridge.dart';
import 'package:dart_edge_s3_client/dart_edge_s3_client.dart';
import 'package:hippobase_storage_models/hippobase_storage_models.dart';

import '../key_validation.dart';
import '../storage_provider.dart';
import '../storage_download_stream.dart';
import '../storage_native_download.dart';
import '../storage_native_provider.dart';

/// Storage provider backed by an S3-compatible bucket.
final class S3StorageProvider
    implements
        StorageProvider,
        NativeStreamingStorageProvider,
        NativeRangedStreamingStorageProvider,
        NativeStreamingUploadStorageProvider {
  const S3StorageProvider({required this.client, required this.bucket});

  final DartEdgeS3Client client;
  final String bucket;

  @override
  Future<void> close() async {
    client.dispose();
  }

  @override
  Future<void> delete(String key) async {
    validateStorageKey(key);
    await client.deleteObject(S3ObjectRef(bucket: bucket, key: key));
  }

  @override
  Future<StorageObject> download(String key) async {
    validateStorageKey(key);
    final object = await client.getObjectBytes(
      S3ObjectRef(bucket: bucket, key: key),
    );

    return StorageObject(
      bytes: object.bytes,
      metadata: _metadataFromS3(object.metadata),
    );
  }

  @override
  Future<StorageDownloadStream> downloadStream(String key) async {
    validateStorageKey(key);
    final object = await client.getObjectStream(
      S3ObjectRef(bucket: bucket, key: key),
    );
    return StorageDownloadStream(
      body: object.body,
      metadata: _metadataFromS3(object.metadata),
      onClose: object.close,
    );
  }

  @override
  Future<StorageNativeDownloadStream> downloadNativeStream(String key) async {
    validateStorageKey(key);
    final object = await client.getObjectNativeStream(
      S3ObjectRef(bucket: bucket, key: key),
    );
    return StorageNativeDownloadStream(
      body: object.body,
      metadata: _metadataFromS3(object.metadata),
    );
  }

  @override
  Future<StorageNativeDownloadStream> downloadNativeRangeStream(
    String key,
    StorageByteRange range,
  ) async {
    validateStorageKey(key);
    final object = await client.getObjectNativeStream(
      S3ObjectRef(bucket: bucket, key: key),
      range: _httpRange(range),
    );
    return StorageNativeDownloadStream(
      body: object.body,
      metadata: _metadataFromS3(object.metadata),
    );
  }

  @override
  Future<bool> exists(String key) async {
    validateStorageKey(key);
    try {
      await getMetadata(key);
      return true;
    } on Object {
      return false;
    }
  }

  @override
  Future<StorageObjectMetadata> getMetadata(String key) async {
    validateStorageKey(key);
    return _metadataFromS3(
      await client.headObject(S3ObjectRef(bucket: bucket, key: key)),
    );
  }

  @override
  Future<void> upload(
    String key,
    Uint8List bytes, {
    StorageWriteOptions options = const StorageWriteOptions(),
  }) async {
    validateStorageKey(key);
    await client.putObjectBytes(
      S3PutObjectBytesRequest(
        bucket: bucket,
        key: key,
        bytes: bytes,
        contentType: options.contentType,
        cacheControl: options.cacheControl,
        contentDisposition: options.contentDisposition,
        contentEncoding: options.contentEncoding,
        contentLanguage: options.contentLanguage,
        metadata: options.metadata,
      ),
    );
  }

  @override
  Future<void> uploadNativeStream(
    String key,
    NativeByteStreamHandle body, {
    required int contentLength,
    StorageWriteOptions options = const StorageWriteOptions(),
  }) async {
    validateStorageKey(key);
    await client.putObjectNativeStream(
      bucket: bucket,
      key: key,
      body: body,
      contentLength: contentLength,
      contentType: options.contentType,
      cacheControl: options.cacheControl,
      contentDisposition: options.contentDisposition,
      contentEncoding: options.contentEncoding,
      contentLanguage: options.contentLanguage,
      metadata: options.metadata,
    );
  }
}

StorageObjectMetadata _metadataFromS3(S3ObjectMetadata metadata) {
  return StorageObjectMetadata(
    contentLength: metadata.contentLength,
    objectLength: metadata.objectLength ?? metadata.contentLength,
    versionId: metadata.versionId,
    eTag: metadata.eTag,
    contentType: metadata.contentType,
    cacheControl: metadata.cacheControl,
    contentDisposition: metadata.contentDisposition,
    contentEncoding: metadata.contentEncoding,
    contentLanguage: metadata.contentLanguage,
    metadata: metadata.metadata,
  );
}

HttpByteRange _httpRange(StorageByteRange range) {
  if (range.suffixLength case final suffixLength?) {
    return HttpByteRange.suffix(suffixLength);
  }
  if (range.end case final end?) {
    return HttpByteRange.closed(range.start!, end);
  }
  return HttpByteRange.from(range.start!);
}
