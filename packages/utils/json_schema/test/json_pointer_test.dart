import 'package:json_schema/json_schema.dart';
import 'package:test/test.dart';

void main() {
  group('JsonPointer', () {
    test('round-trips the RFC 6901 examples', () {
      const expectedSegments = <String, List<String>>{
        '': <String>[],
        '/foo': <String>['foo'],
        '/foo/0': <String>['foo', '0'],
        '/': <String>[''],
        '/a~1b': <String>['a/b'],
        '/c%d': <String>['c%d'],
        '/e^f': <String>['e^f'],
        '/g|h': <String>['g|h'],
        '/i\\j': <String>['i\\j'],
        '/k"l': <String>['k"l'],
        '/ ': <String>[' '],
        '/m~0n': <String>['m~n'],
      };

      for (final entry in expectedSegments.entries) {
        final pointer = JsonPointer(entry.key);

        expect(pointer.segments, entry.value, reason: entry.key);
        expect(pointer.toString(), entry.key, reason: entry.key);
      }
    });

    test('rejects invalid string representations and escapes', () {
      for (final value in <String>['foo', '#/foo', '/foo~', '/foo~2bar']) {
        expect(() => JsonPointer(value), throwsFormatException, reason: value);
      }
    });

    test('navigates without mutating either pointer', () {
      const root = JsonPointer.empty();
      final escaped = root.child('a/b').child('m~n');

      expect(root, JsonPointer.root);
      expect(root.isRoot, isTrue);
      expect(root.parent(), same(root));
      expect(escaped.toString(), '/a~1b/m~0n');
      expect(escaped.parent(), JsonPointer('/a~1b'));
      expect(escaped.parent().parent(), root);
      expect(() => escaped.segments.add('nope'), throwsUnsupportedError);
    });

    test('resolves objects, arrays, escaped keys, and JSON null', () {
      final document = <String, Object?>{
        'foo': <Object?>['bar', 'baz'],
        '': 0,
        'a/b': 1,
        'm~n': 8,
        'nullable': null,
      };

      expect(JsonPointer.root.read(document), same(document));
      expect(JsonPointer('/foo/0').read(document), 'bar');
      expect(JsonPointer('/a~1b').read(document), 1);
      expect(JsonPointer('/m~0n').read(document), 8);
      expect(JsonPointer('/nullable').read(document), isNull);
      expect(JsonPointer('/nullable').existsIn(document), isTrue);
      expect(JsonPointer('/missing').read(document), isNull);
      expect(JsonPointer('/missing').existsIn(document), isFalse);
    });

    test('accepts only canonical non-negative array indices', () {
      final document = <Object?>['zero', 'one'];

      expect(JsonPointer('/1').read(document), 'one');
      for (final path in <String>['/-', '/01', '/+1', '/-1', '/2']) {
        expect(JsonPointer(path).existsIn(document), isFalse, reason: path);
      }
    });

    test('compares pointers by decoded segments', () {
      final first = JsonPointer('/a~1b/m~0n');
      final second = JsonPointer.root.child('a/b').child('m~n');

      expect(first, second);
      expect(first.hashCode, second.hashCode);
      expect(<JsonPointer>{first, second}, hasLength(1));
    });

    test('provides lookup helpers', () {
      final document = <String, Object?>{'value': 42};

      expect(jsonValueAtPointer(document, '/value'), 42);
      expect(jsonPointerExists(document, '/value'), isTrue);
      expect(jsonPointerExists(document, '/missing'), isFalse);
    });

    test('publishes its JSON Schema contract', () {
      expect(JsonPointer.schema.id, JsonPointer.schemaId);
      expect(JsonPointer.schema.toJson(), <String, Object?>{
        r'$id': 'JsonPointer',
        'type': 'string',
        'pattern': r'^(?:/(?:[^~/]|~[01])*)*$',
        'description': 'An RFC 6901 JSON Pointer in string representation.',
      });
    });
  });
}
