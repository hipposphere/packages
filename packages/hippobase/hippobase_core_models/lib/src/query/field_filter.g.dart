// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'field_filter.dart';

// **************************************************************************
// DartEdgeHttpServerBuilderGenerator
// **************************************************************************

// ignore_for_file: unused_element, unused_field
final class _$FieldFilter implements JsonEncodable {
  const _$FieldFilter({required this.field, required this.operatorValue, this.value});

  static const schemaId = 'FieldFilter';

  static const JsonSchema schema = JsonSchema.object(
    id: schemaId,
    properties: <String, JsonSchema>{
      'field': JsonSchema.string(),
      'operator': JsonSchema.ref('#/components/schemas/FilterOperator'),
      'value': JsonSchema.any(),
    },
    required: <String>['field', 'operator'],
    additionalProperties: false,
  );

  static const schemaRef = JsonSchema.componentRef(schemaId);

  static const RequestBody requestBody = RequestBody.json(schema: schema, decoder: decode);

  static const ResponseSpec response = ResponseSpec.json(status: 200, schema: schema);

  final String field;

  final FilterOperator operatorValue;

  final Object? value;

  @override
  Map<String, Object?> toJson() {
    return <String, Object?>{"field": field, "operator": operatorValue.toJson(), "value": value};
  }

  static FieldFilter decode(Object? value) {
    return fromJson(readJsonObject(value));
  }

  static FieldFilter fromJson(Map<String, Object?> json) {
    return FieldFilter(
      field: json["field"]! as String,
      operatorValue: FilterOperator.decode(json["operator"]),
      value: json["value"],
    );
  }
}
