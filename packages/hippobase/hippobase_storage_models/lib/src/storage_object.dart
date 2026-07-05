import 'dart:typed_data';

import 'storage_object_metadata.dart';

/// Bytes downloaded from storage together with the object's metadata.
final class StorageObject {
  const StorageObject({required this.bytes, required this.metadata});

  final Uint8List bytes;
  final StorageObjectMetadata metadata;
}
