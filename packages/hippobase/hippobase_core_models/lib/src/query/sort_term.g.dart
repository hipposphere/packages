// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sort_term.dart';

// **************************************************************************
// DartEdgeHttpServerBuilderGenerator
// **************************************************************************

// ignore_for_file: unused_element, unused_field
enum _$SortDirection implements JsonEncodable {
  asc('asc'),
  desc('desc');

  const _$SortDirection(this.value);

  final String value;

  static const schemaId = 'SortDirection';

  static const JsonSchema schema = JsonSchema.string(id: schemaId, enumValues: ['asc', 'desc']);

  static const schemaRef = JsonSchema.componentRef(schemaId);

  static const RequestBody requestBody = RequestBody.json(schema: schema, decoder: decode);

  static const ResponseSpec response = ResponseSpec.json(status: 200, schema: schema);

  @override
  String toJson() => value;

  static SortDirection decode(Object? value) {
    return fromJson(value);
  }

  static SortDirection fromJson(Object? value) {
    return switch (value) {
      "asc" => SortDirection.asc,
      "desc" => SortDirection.desc,
      _ => throw ArgumentError.value(value, 'value', 'Expected SortDirection JSON enum value.'),
    };
  }
}

final class _$SortTerm implements JsonEncodable {
  const _$SortTerm({required this.field, required this.direction});

  static const schemaId = 'SortTerm';

  static const JsonSchema schema = JsonSchema.object(
    id: schemaId,
    properties: <String, JsonSchema>{
      'field': JsonSchema.string(),
      'direction': JsonSchema.ref('#/components/schemas/SortDirection'),
    },
    required: <String>['field', 'direction'],
    additionalProperties: false,
  );

  static const schemaRef = JsonSchema.componentRef(schemaId);

  static const RequestBody requestBody = RequestBody.json(schema: schema, decoder: decode);

  static const ResponseSpec response = ResponseSpec.json(status: 200, schema: schema);

  final String field;

  final SortDirection direction;

  @override
  Map<String, Object?> toJson() {
    return <String, Object?>{"field": field, "direction": direction.toJson()};
  }

  static SortTerm decode(Object? value) {
    return fromJson(readJsonObject(value));
  }

  static SortTerm fromJson(Map<String, Object?> json) {
    return SortTerm(
      field: json["field"]! as String,
      direction: SortDirection.decode(json["direction"]),
    );
  }
}
