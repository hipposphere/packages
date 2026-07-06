// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'filter_combinator.dart';

// **************************************************************************
// DartEdgeHttpServerBuilderGenerator
// **************************************************************************

// ignore_for_file: unused_element, unused_field
enum _$FilterCombinator implements JsonEncodable {
  and('and'),
  or('or');

  const _$FilterCombinator(this.value);

  final String value;

  static const schemaId = 'FilterCombinator';

  static const JsonSchema schema = JsonSchema.string(id: schemaId, enumValues: ['and', 'or']);

  static const schemaRef = JsonSchema.componentRef(schemaId);

  static const RequestBody requestBody = RequestBody.json(schema: schema, decoder: decode);

  static const ResponseSpec response = ResponseSpec.json(status: 200, schema: schema);

  @override
  String toJson() => value;

  static FilterCombinator decode(Object? value) {
    return fromJson(value);
  }

  static FilterCombinator fromJson(Object? value) {
    return switch (value) {
      "and" => FilterCombinator.and,
      "or" => FilterCombinator.or,
      _ => throw ArgumentError.value(value, 'value', 'Expected FilterCombinator JSON enum value.'),
    };
  }
}
