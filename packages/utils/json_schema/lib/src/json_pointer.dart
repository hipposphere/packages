import 'json_schema.dart';

/// An immutable JSON Pointer using the string representation from RFC 6901.
///
/// The empty string addresses the complete document. Non-root pointers start
/// with `/`, and their reference tokens escape `~` as `~0` and `/` as `~1`.
/// URI fragment identifiers such as `#/items/0` are intentionally not parsed.
final class JsonPointer {
  /// Parses an RFC 6901 JSON Pointer string.
  ///
  /// Throws a [FormatException] when [pointer] is neither empty nor starts with
  /// `/`, or when it contains an invalid `~` escape sequence.
  factory JsonPointer(String pointer) {
    if (pointer.isEmpty) {
      return const JsonPointer.empty();
    }
    if (!pointer.startsWith('/')) {
      throw FormatException('A JSON Pointer must start with "/" or be empty.', pointer);
    }

    return JsonPointer._(
      pointer.substring(1).split('/').map((segment) => _decodeSegment(segment, pointer)),
    );
  }

  /// Creates the root pointer, represented by an empty string.
  const JsonPointer.empty() : segments = const <String>[];

  JsonPointer._(Iterable<String> segments) : segments = List<String>.unmodifiable(segments);

  /// Stable schema identifier for [schema].
  static const schemaId = 'JsonPointer';

  /// JSON Schema for an RFC 6901 JSON Pointer string.
  static const schema = JsonSchema.raw(<String, Object?>{
    'type': 'string',
    'pattern': r'^(?:/(?:[^~/]|~[01])*)*$',
    'description': 'An RFC 6901 JSON Pointer in string representation.',
  }, id: schemaId);

  /// The root pointer.
  static const root = JsonPointer.empty();

  /// Decoded reference tokens in document traversal order.
  final List<String> segments;

  /// Whether this pointer addresses the complete document.
  bool get isRoot => segments.isEmpty;

  /// Returns a pointer with [segment] appended as one reference token.
  JsonPointer child(String segment) => JsonPointer._(<String>[...segments, segment]);

  /// Returns this pointer without its final reference token.
  ///
  /// The root pointer is its own parent.
  JsonPointer parent() {
    if (isRoot) {
      return this;
    }
    return JsonPointer._(segments.take(segments.length - 1));
  }

  /// Reads the value addressed by this pointer from decoded JSON [document].
  ///
  /// Returns `null` both when the pointer does not resolve and when it resolves
  /// to JSON `null`. Use [existsIn] to distinguish those cases.
  Object? read(Object? document) => _resolve(document).value;

  /// Whether this pointer resolves inside decoded JSON [document].
  bool existsIn(Object? document) => _resolve(document).found;

  _JsonPointerLookupResult _resolve(Object? document) {
    var current = document;

    for (final segment in segments) {
      if (current is Map<Object?, Object?>) {
        if (!current.containsKey(segment)) {
          return const _JsonPointerLookupResult.notFound();
        }
        current = current[segment];
        continue;
      }

      if (current is List<Object?>) {
        final index = _tryParseArrayIndex(segment);
        if (index == null || index >= current.length) {
          return const _JsonPointerLookupResult.notFound();
        }
        current = current[index];
        continue;
      }

      return const _JsonPointerLookupResult.notFound();
    }

    return _JsonPointerLookupResult.found(current);
  }

  static String _decodeSegment(String segment, String pointer) {
    final result = StringBuffer();

    for (var index = 0; index < segment.length; index++) {
      final codeUnit = segment.codeUnitAt(index);
      if (codeUnit != 0x7e) {
        result.writeCharCode(codeUnit);
        continue;
      }

      if (index + 1 >= segment.length) {
        throw FormatException('A JSON Pointer contains an incomplete "~" escape.', pointer);
      }

      final escape = segment.codeUnitAt(++index);
      switch (escape) {
        case 0x30:
          result.write('~');
        case 0x31:
          result.write('/');
        default:
          throw FormatException('A JSON Pointer only supports "~0" and "~1" escapes.', pointer);
      }
    }

    return result.toString();
  }

  static int? _tryParseArrayIndex(String segment) {
    if (segment == '-') {
      return null;
    }

    final index = int.tryParse(segment);
    if (index == null || index < 0 || index.toString() != segment) {
      return null;
    }
    return index;
  }

  @override
  String toString() {
    if (isRoot) {
      return '';
    }

    return segments
        .map((segment) => '/${segment.replaceAll('~', '~0').replaceAll('/', '~1')}')
        .join();
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! JsonPointer || segments.length != other.segments.length) {
      return false;
    }

    for (var index = 0; index < segments.length; index++) {
      if (segments[index] != other.segments[index]) {
        return false;
      }
    }
    return true;
  }

  @override
  int get hashCode => Object.hashAll(segments);
}

/// Reads decoded JSON [document] at JSON Pointer [path].
Object? jsonValueAtPointer(Object? document, String path) => JsonPointer(path).read(document);

/// Whether JSON Pointer [path] resolves inside decoded JSON [document].
bool jsonPointerExists(Object? document, String path) => JsonPointer(path).existsIn(document);

final class _JsonPointerLookupResult {
  const _JsonPointerLookupResult._({required this.found, this.value});

  const _JsonPointerLookupResult.found(Object? value) : this._(found: true, value: value);

  const _JsonPointerLookupResult.notFound() : this._(found: false);

  final bool found;
  final Object? value;
}
