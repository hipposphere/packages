import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:hippobase_storage_models/hippobase_storage_models.dart';

import '../key_validation.dart';
import '../storage_provider.dart';

/// Stores objects as files below [baseDirectory].
final class FileSystemStorageProvider implements StorageProvider {
  const FileSystemStorageProvider({required this.baseDirectory});

  final Directory baseDirectory;

  @override
  Future<void> close() async {}

  @override
  Future<void> delete(String key) async {
    validateStorageKey(key);
    final file = _fileForKey(key);
    final metadataFile = _metadataFileForKey(key);
    if (await file.exists()) {
      await file.delete();
    }
    if (await metadataFile.exists()) {
      await metadataFile.delete();
    }
  }

  @override
  Future<StorageObject> download(String key) async {
    validateStorageKey(key);
    final file = _fileForKey(key);
    final bytes = await file.readAsBytes();
    final metadata = await getMetadata(key);

    return StorageObject(
      bytes: bytes,
      metadata: metadata.copyWith(contentLength: bytes.length),
    );
  }

  @override
  Future<bool> exists(String key) {
    validateStorageKey(key);
    return _fileForKey(key).exists();
  }

  @override
  Future<StorageObjectMetadata> getMetadata(String key) async {
    validateStorageKey(key);
    final file = _fileForKey(key);
    final metadataFile = _metadataFileForKey(key);
    if (!await file.exists()) {
      throw StateError('No object exists for key "$key".');
    }

    final length = await file.exists() ? await file.length() : null;

    if (!await metadataFile.exists()) {
      return StorageObjectMetadata(contentLength: length);
    }

    final metadataJson = jsonDecode(await metadataFile.readAsString()) as Map<String, Object?>;
    return _metadataFromJson(metadataJson).copyWith(contentLength: length);
  }

  @override
  Future<void> upload(
    String key,
    Uint8List bytes, {
    StorageWriteOptions options = const StorageWriteOptions(),
  }) async {
    validateStorageKey(key);
    final file = _fileForKey(key);
    await file.parent.create(recursive: true);
    await file.writeAsBytes(bytes, flush: true);

    final metadata = options.toMetadata(contentLength: bytes.length);
    await _metadataFileForKey(
      key,
    ).writeAsString(jsonEncode(_metadataToJson(metadata)), flush: true);
  }

  File _fileForKey(String key) {
    final basePath = baseDirectory.absolute.path;
    final file = File('$basePath/$key').absolute;
    final normalizedBasePath = _withTrailingSeparator(basePath);

    if (!file.path.startsWith(normalizedBasePath)) {
      throw ArgumentError.value(key, 'key', 'key must stay inside the storage directory.');
    }

    return file;
  }

  File _metadataFileForKey(String key) {
    return File('${_fileForKey(key).path}.metadata.json');
  }
}

String _withTrailingSeparator(String path) {
  if (path.endsWith(Platform.pathSeparator)) {
    return path;
  }
  return '$path${Platform.pathSeparator}';
}

Map<String, Object?> _metadataToJson(StorageObjectMetadata metadata) {
  return <String, Object?>{
    'versionId': metadata.versionId,
    'eTag': metadata.eTag,
    'contentType': metadata.contentType,
    'cacheControl': metadata.cacheControl,
    'contentDisposition': metadata.contentDisposition,
    'contentEncoding': metadata.contentEncoding,
    'contentLanguage': metadata.contentLanguage,
    'metadata': metadata.metadata,
  };
}

StorageObjectMetadata _metadataFromJson(Map<String, Object?> json) {
  final metadata = json['metadata'] as Map<Object?, Object?>? ?? const <Object?, Object?>{};
  return StorageObjectMetadata(
    versionId: json['versionId'] as String?,
    eTag: json['eTag'] as String?,
    contentType: json['contentType'] as String?,
    cacheControl: json['cacheControl'] as String?,
    contentDisposition: json['contentDisposition'] as String?,
    contentEncoding: json['contentEncoding'] as String?,
    contentLanguage: json['contentLanguage'] as String?,
    metadata: Map.unmodifiable(<String, String>{
      for (final entry in metadata.entries) entry.key.toString(): entry.value.toString(),
    }),
  );
}
