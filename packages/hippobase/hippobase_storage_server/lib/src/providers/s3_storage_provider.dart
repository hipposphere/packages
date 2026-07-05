import 'dart:typed_data';

import 'package:dart_edge_s3_client/dart_edge_s3_client.dart';
import 'package:hippobase_storage_models/hippobase_storage_models.dart';

import '../key_validation.dart';
import '../storage_provider.dart';

/// Storage provider backed by an S3-compatible bucket.
final class S3StorageProvider implements StorageProvider {
  const S3StorageProvider({required this.client, required this.bucket});

  final DartEdgeS3Client client;
  final String bucket;

  @override
  Future<void> delete(String key) async {
    validateStorageKey(key);
    await client.deleteObject(S3ObjectRef(bucket: bucket, key: key));
  }

  @override
  Future<StorageObject> download(String key) async {
    validateStorageKey(key);
    final object = await client.getObjectBytes(S3ObjectRef(bucket: bucket, key: key));

    return StorageObject(bytes: object.bytes, metadata: _metadataFromS3(object.metadata));
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
    return _metadataFromS3(await client.headObject(S3ObjectRef(bucket: bucket, key: key)));
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
}

StorageObjectMetadata _metadataFromS3(S3ObjectMetadata metadata) {
  return StorageObjectMetadata(
    contentLength: metadata.contentLength,
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
