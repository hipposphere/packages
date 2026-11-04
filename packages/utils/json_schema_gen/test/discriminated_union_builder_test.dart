import 'dart:io';

import 'package:build/build.dart';
import 'package:build_test/build_test.dart';
import 'package:json_schema_gen/builder.dart';
import 'package:test/test.dart';

const _variants = r'''
import 'package:json_schema/json_schema.dart';

part 'variants.g.dart';

@FromSchema(
  JsonSchema.object(
    id: 'PhaseLine',
    properties: <String, JsonSchema>{
      'type': JsonSchema.string(enumValues: <Object?>['phase']),
      'phase': JsonSchema.string(),
    },
    required: <String>['type', 'phase'],
  ),
)
typedef PhaseLine = _$PhaseLine;

@FromSchema(
  JsonSchema.object(
    id: 'KeepaliveLine',
    properties: <String, JsonSchema>{'type': JsonSchema.string()},
    required: <String>['type'],
  ),
)
typedef KeepaliveLine = _$KeepaliveLine;
''';

/// Runs the builder on `lib/model.dart` and returns its generated part, or the
/// build errors when generation fails.
Future<({String output, List<String> errors})> _build(String model) async {
  final readerWriter = TestReaderWriter(rootPackage: 'test_app');
  await readerWriter.testing.loadIsolateSources();
  final result = await testBuilder(
    jsonSchemaBuilder(BuilderOptions.empty),
    <String, String>{
      'test_app|lib/variants.dart': _variants,
      'test_app|lib/model.dart':
          "import 'package:json_schema/json_schema.dart';\n\n"
          "import 'variants.dart';\n\n"
          "part 'model.g.dart';\n\n$model",
    },
    readerWriter: readerWriter,
    flattenOutput: true,
  );
  final outputId = AssetId('test_app', 'lib/model.json_schema.g.part');
  final output = readerWriter.testing.exists(outputId)
      ? readerWriter.testing.readString(outputId)
      : '';
  return (output: output, errors: result.errors.toList());
}

void main() {
  test('generates a sealed union from an explicit mapping', () async {
    final result = await _build(r'''
@FromSchema(
  JsonSchema.oneOf(
    <JsonSchema>[JsonSchema.componentRef('PhaseLine'), JsonSchema.componentRef('KeepaliveLine')],
    id: 'Line',
    discriminator: JsonDiscriminator(
      propertyName: 'type',
      mapping: <String, String>{'keepalive': 'KeepaliveLine'},
    ),
  ),
)
typedef Line = _$Line;
''');

    expect(result.errors, isEmpty);
    final output = result.output;
    expect(output, contains(r'sealed class _$Line implements JsonEncodable'));
    expect(output, contains(r'final class Line$Phase extends Line'));
    expect(output, contains(r'final class Line$Keepalive extends Line'));
    expect(output, contains(r'"phase" => Line$Phase(PhaseLine.fromJson(json)),'));
    expect(output, contains(r'"keepalive" => Line$Keepalive(KeepaliveLine.fromJson(json)),'));
    expect(output, contains('final value => throw FormatException('));
    expect(output, isNot(contains(r'Line$Unknown')));
    // The emitted schema keeps its branches and completes the mapping.
    expect(output, contains("JsonSchema.ref('#/components/schemas/PhaseLine')"));
    expect(
      output,
      contains("mapping: <String, String>{'keepalive': 'KeepaliveLine', 'phase': 'PhaseLine'}"),
    );
    expect(output, isNot(contains('const <JsonSchema>')));
  });

  test('generates an unknown fallback variant on request', () async {
    final result = await _build(r'''
@FromSchema(
  JsonSchema.oneOf(
    <JsonSchema>[JsonSchema.componentRef('PhaseLine')],
    discriminator: JsonDiscriminator(propertyName: 'type'),
  ),
  unknownVariant: true,
)
typedef Line = _$Line;
''');

    expect(result.errors, isEmpty);
    final output = result.output;
    expect(output, contains(r'final class Line$Unknown extends Line'));
    expect(output, contains(r'_ => Line$Unknown(json),'));
    expect(output, contains('Object? get discriminatorValue => json["type"];'));
  });

  test('types union, list, and nullable properties', () async {
    final result = await _build(r'''
@FromSchema(
  JsonSchema.oneOf(
    <JsonSchema>[JsonSchema.componentRef('PhaseLine')],
    id: 'Line',
    discriminator: JsonDiscriminator(propertyName: 'type'),
  ),
)
typedef Line = _$Line;

@FromSchema(
  JsonSchema.object(
    id: 'Holder',
    properties: <String, JsonSchema>{
      'line': JsonSchema.componentRef('Line'),
      'lines': JsonSchema.array(items: JsonSchema.componentRef('Line')),
      'maybe': JsonSchema.anyOf(<JsonSchema>[JsonSchema.componentRef('Line'), JsonSchema.nullType()]),
      'phase': JsonSchema.oneOf(<JsonSchema>[JsonSchema.nullType(), JsonSchema.componentRef('PhaseLine')]),
      'count': JsonSchema.anyOf(<JsonSchema>[JsonSchema.integer(), JsonSchema.nullType()]),
      'inline': JsonSchema.anyOf(<JsonSchema>[
        JsonSchema.oneOf(
          <JsonSchema>[JsonSchema.componentRef('PhaseLine')],
          discriminator: JsonDiscriminator(propertyName: 'type'),
        ),
        JsonSchema.nullType(),
      ]),
      'loose': JsonSchema.anyOf(<JsonSchema>[JsonSchema.string(), JsonSchema.integer()]),
    },
    required: <String>['line', 'lines', 'maybe', 'phase', 'count', 'inline', 'loose'],
  ),
)
typedef Holder = _$Holder;
''');

    expect(result.errors, isEmpty);
    final output = result.output;
    expect(output, contains('final Line line;'));
    expect(output, contains('final List<Line> lines;'));
    expect(output, contains('final Line? maybe;'));
    expect(output, contains('final PhaseLine? phase;'));
    expect(output, contains('final int? count;'));
    expect(output, contains('final HolderInline? inline;'));
    expect(output, contains('final Object? loose;'));
    expect(output, contains('sealed class HolderInline implements JsonEncodable'));
    expect(output, contains('maybe: json["maybe"] == null ? null : Line.decode(json["maybe"]),'));
    expect(
      output,
      contains('phase: json["phase"] == null ? null : PhaseLine.decode(json["phase"]),'),
    );
    expect(output, contains('"phase": phase?.toJson(),'));
    expect(output, contains('count: json["count"] as int?,'));
    expect(output, contains('"inline": inline?.toJson(),'));
    expect(output, contains('JsonSchema.nullType()'));
  });

  test('rejects branches without a discoverable tag', () async {
    final result = await _build(r'''
@FromSchema(
  JsonSchema.oneOf(
    <JsonSchema>[JsonSchema.componentRef('PhaseLine'), JsonSchema.componentRef('KeepaliveLine')],
    discriminator: JsonDiscriminator(propertyName: 'type'),
  ),
)
typedef Line = _$Line;
''');

    expect(
      result.errors.join('\n'),
      contains('Cannot determine the "type" discriminator value of KeepaliveLine in Line.'),
    );
  });

  test('rejects mappings that disagree with the referenced schema', () async {
    final result = await _build(r'''
@FromSchema(
  JsonSchema.oneOf(
    <JsonSchema>[JsonSchema.componentRef('PhaseLine')],
    discriminator: JsonDiscriminator(
      propertyName: 'type',
      mapping: <String, String>{'stage': 'PhaseLine'},
    ),
  ),
)
typedef Line = _$Line;
''');

    expect(result.errors.join('\n'), contains('pins "type" to "phase"'));
  });

  test('rejects inline object branches', () async {
    final result = await _build(r'''
@FromSchema(
  JsonSchema.oneOf(
    <JsonSchema>[JsonSchema.object()],
    discriminator: JsonDiscriminator(propertyName: 'type'),
  ),
)
typedef Line = _$Line;
''');

    expect(result.errors.join('\n'), contains('only supports component reference branches'));
  });

  test('checked-in fixtures match the generator output', () async {
    final readerWriter = TestReaderWriter(rootPackage: 'json_schema_gen');
    await readerWriter.testing.loadIsolateSources();
    const fixtures = <String>['stream_lines', 'unions'];
    String source(String path) => File(path).readAsStringSync();

    final result = await testBuilder(
      jsonSchemaBuilder(BuilderOptions.empty),
      <String, String>{
        for (final fixture in fixtures)
          'json_schema_gen|test/fixtures/$fixture.dart': source('test/fixtures/$fixture.dart'),
      },
      readerWriter: readerWriter,
      flattenOutput: true,
    );

    expect(result.errors, isEmpty);
    for (final fixture in fixtures) {
      final generated = readerWriter.testing.readString(
        AssetId('json_schema_gen', 'test/fixtures/$fixture.json_schema.g.part'),
      );
      expect(
        source('test/fixtures/$fixture.g.dart'),
        contains(generated.trim()),
        reason: 'Regenerate with `dart run build_runner build` in json_schema_gen.',
      );
    }
  });
}
