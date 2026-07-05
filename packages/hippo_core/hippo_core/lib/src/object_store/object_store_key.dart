/*
// ---------------------------------------------------------------------------
// Copyright (c) 2025 HippoSphere UG (haftungsbeschränkt). All rights reserved.
// Use, copying, modification, or distribution of this software is prohibited
// without express written permission from Hipposphere UG.
//
// SPDX-License-Identifier: LicenseRef-Hipposphere-Proprietary
// ---------------------------------------------------------------------------
*/
final class ObjectStoreKey {
  static final root = ObjectStoreKey(const <String>[]);

  ObjectStoreKey(Iterable<String> segments) : segments = List.unmodifiable(segments) {
    for (final segment in this.segments) {
      _validateSegment(segment);
    }
  }

  factory ObjectStoreKey.fromPath(String path) {
    final trimmedPath = path.trim();
    if (trimmedPath.isEmpty || trimmedPath == '/') {
      return ObjectStoreKey.root;
    }
    return ObjectStoreKey(trimmedPath.split('/'));
  }

  factory ObjectStoreKey.fromEncodedPath(String path) {
    final trimmedPath = path.trim();
    if (trimmedPath.isEmpty || trimmedPath == '/') {
      return ObjectStoreKey.root;
    }
    return ObjectStoreKey(trimmedPath.split('/').map(Uri.decodeComponent));
  }

  final List<String> segments;

  bool get isRoot => segments.isEmpty;

  String get path => segments.join('/');

  String get encodedPath => encodedSegments.join('/');

  List<String> get encodedSegments => segments.map(Uri.encodeComponent).toList(growable: false);

  ObjectStoreKey child(String segment) {
    return ObjectStoreKey([...segments, segment]);
  }

  ObjectStoreKey resolve(Iterable<String> childSegments) {
    return ObjectStoreKey([...segments, ...childSegments]);
  }

  bool isPrefixOf(ObjectStoreKey other) {
    if (segments.length > other.segments.length) {
      return false;
    }
    for (var index = 0; index < segments.length; index += 1) {
      if (segments[index] != other.segments[index]) {
        return false;
      }
    }
    return true;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! ObjectStoreKey || other.segments.length != segments.length) {
      return false;
    }
    for (var index = 0; index < segments.length; index += 1) {
      if (segments[index] != other.segments[index]) {
        return false;
      }
    }
    return true;
  }

  @override
  int get hashCode => Object.hashAll(segments);

  @override
  String toString() => isRoot ? '<root>' : path;

  static void _validateSegment(String segment) {
    if (segment.isEmpty) {
      throw ArgumentError.value(segment, 'segment', 'Object store key segments cannot be empty.');
    }
    if (segment == '.' || segment == '..') {
      throw ArgumentError.value(
        segment,
        'segment',
        'Object store key segments cannot be "." or "..".',
      );
    }
    if (segment.contains('/') || segment.contains('\\') || segment.contains('\x00')) {
      throw ArgumentError.value(
        segment,
        'segment',
        'Object store key segments cannot contain path separators or null bytes.',
      );
    }
  }
}
