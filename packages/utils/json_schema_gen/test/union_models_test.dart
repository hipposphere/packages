import 'package:json_schema/json_schema.dart';
import 'package:test/test.dart';

import 'fixtures/stream_lines.dart';
import 'fixtures/unions.dart';

/// Exhaustive without a default branch: adding a variant breaks compilation.
String describe(StreamLine line) => switch (line) {
  StreamLine$Phase(:final value) => 'phase ${value.phase}',
  StreamLine$Keepalive() => 'keepalive',
  StreamLine$Result(:final value) => 'result ${value.data.length}',
};

String describeTolerant(TolerantStreamLine line) => switch (line) {
  TolerantStreamLine$Phase(:final value) => value.phase,
  TolerantStreamLine$Keepalive() => 'keepalive',
  TolerantStreamLine$Unknown(:final discriminatorValue) => 'unknown $discriminatorValue',
};

void main() {
  group('discriminated union', () {
    test('decodes each variant by its inferred tag and round-trips', () {
      final lines = <Map<String, Object?>>[
        {'type': 'phase', 'phase': 'parsing'},
        {'type': 'keepalive'},
        {
          'type': 'result',
          'data': {'pages': 3},
        },
      ];

      final decoded = [for (final json in lines) StreamLine.fromJson(json)];

      expect(decoded.map(describe), ['phase parsing', 'keepalive', 'result 1']);
      expect(decoded.first, isA<StreamLine$Phase>());
      expect([for (final line in decoded) line.toJson()], lines);
      expect(StreamLine.decode(lines[1]), isA<StreamLine$Keepalive>());
    });

    test('throws a FormatException for unknown or missing tags by default', () {
      expect(
        () => StreamLine.fromJson(const {'type': 'progress'}),
        throwsA(
          isA<FormatException>().having(
            (error) => error.message,
            'message',
            'Unknown StreamLine "type" discriminator value: progress',
          ),
        ),
      );
      expect(() => StreamLine.fromJson(const <String, Object?>{}), throwsFormatException);
    });

    test('opt-in unknown variant preserves the raw JSON', () {
      const json = <String, Object?>{'type': 'progress', 'percent': 42};

      final line = TolerantStreamLine.fromJson(json);

      expect(line, isA<TolerantStreamLine$Unknown>());
      expect(describeTolerant(line), 'unknown progress');
      expect(line.toJson(), json);
      expect(
        describeTolerant(TolerantStreamLine.fromJson(const {'type': 'keepalive'})),
        'keepalive',
      );
    });

    test('matches non-string discriminator values by their JSON value', () {
      final present = Role.fromJson(const {'configured': true, 'name': 'ocr'});
      final absent = Role.fromJson(const {'configured': false});

      expect(present, isA<Role$RolePresent>());
      expect((present as Role$RolePresent).value.name, 'ocr');
      expect(absent, isA<Role$RoleAbsent>());
      expect(absent.toJson(), {'configured': false});
      expect(() => Role.fromJson(const {'configured': 'True'}), throwsFormatException);
    });

    test('re-emits every branch and the completed mapping', () {
      final schema = StreamLine.schema as JsonOneOfSchema;

      expect(schema.schemas, hasLength(3));
      expect(schema.toJson(), {
        r'$id': 'StreamLine',
        'oneOf': [
          {r'$ref': '#/components/schemas/PhaseLine'},
          {r'$ref': '#/components/schemas/KeepaliveLine'},
          {r'$ref': '#/components/schemas/ResultLine'},
        ],
        'discriminator': {
          'propertyName': 'type',
          'mapping': {
            'phase': '#/components/schemas/PhaseLine',
            'keepalive': '#/components/schemas/KeepaliveLine',
            'result': '#/components/schemas/ResultLine',
          },
        },
      });
      expect(StreamLine.discriminatorProperty, 'type');
      expect(Role.schema.toJson()['discriminator'], {
        'propertyName': 'configured',
        'mapping': {
          'True': '#/components/schemas/RolePresent',
          'False': '#/components/schemas/RoleAbsent',
        },
      });
    });
  });

  group('union-typed properties', () {
    final json = <String, Object?>{
      'line': {'type': 'keepalive'},
      'lines': [
        {'type': 'phase', 'phase': 'embedding'},
        {'type': 'keepalive'},
      ],
      'previous': {'type': 'phase', 'phase': 'parsing'},
      'role': {'configured': true, 'name': 'embedder'},
      'roles': [
        {'configured': false},
        {'configured': true, 'name': 'ocr'},
      ],
      'keepalive': {'type': 'keepalive'},
      'note': 'hello',
      'detail': {'type': 'phase', 'phase': 'parsing'},
    };

    test('decode references, lists, inline unions, and nullable unions', () {
      final envelope = Envelope.fromJson(json);

      expect(envelope.line, isA<StreamLine$Keepalive>());
      expect(envelope.lines.map(describe), ['phase embedding', 'keepalive']);
      expect(envelope.previous, isA<StreamLine$Phase>());
      expect(envelope.role, isA<EnvelopeRole$RolePresent>());
      expect(switch (envelope.role) {
        EnvelopeRole$RolePresent(:final value) => value.name,
        EnvelopeRole$RoleAbsent() => null,
      }, 'embedder');
      expect(envelope.roles.first, isA<EnvelopeRolesItem$RoleAbsent>());
      expect(envelope.keepalive, isA<KeepaliveLine>());
      expect(envelope.note, 'hello');
      expect(envelope.detail, json['detail']);
      expect(envelope.toJson(), json);
    });

    test('collapse anyOf with null into nullable types', () {
      final envelope = Envelope.fromJson(
        {...json, 'previous': null, 'keepalive': null, 'note': null}..remove('detail'),
      );

      expect(envelope.previous, isNull);
      expect(envelope.keepalive, isNull);
      expect(envelope.note, isNull);
      expect(envelope.toJson(), containsPair('previous', null));
      expect(envelope.toJson(), containsPair('keepalive', null));
    });

    test('keep every composite branch in the emitted object schema', () {
      final properties = (Envelope.schema as JsonObjectSchema).properties;

      final previous = properties['previous']! as JsonAnyOfSchema;
      expect(previous.schemas, hasLength(2));
      expect(previous.schemas.last, isA<JsonNullSchema>());
      expect((properties['detail']! as JsonAnyOfSchema).schemas, hasLength(2));
      expect((properties['role']! as JsonOneOfSchema).discriminator?.propertyName, 'configured');
      expect(
        ((properties['roles']! as JsonArraySchema).items! as JsonOneOfSchema).schemas,
        hasLength(2),
      );
      expect(EnvelopeRole.schema.toJson(), {
        'oneOf': [
          {r'$ref': '#/components/schemas/RolePresent'},
          {r'$ref': '#/components/schemas/RoleAbsent'},
        ],
        'discriminator': {'propertyName': 'configured'},
      });
    });
  });
}
