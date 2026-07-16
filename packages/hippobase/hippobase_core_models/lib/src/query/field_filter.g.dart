// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'field_filter.dart';

// **************************************************************************
// JsonSchemaBuilderGenerator
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

  final String field;

  final FilterOperator operatorValue;

  final Object? value;

  @override
  Map<String, Object?> toJson() {
    return <String, Object?>{"field": field, "operator": operatorValue.toJson(), "value": value};
  }

  static FieldFilter decode(Object? value) {
    return fromJson(value as Map<String, Object?>);
  }

  static FieldFilter fromJson(Map<String, Object?> json) {
    return FieldFilter(
      field: json["field"]! as String,
      operatorValue: FilterOperator.decode(json["operator"]),
      value: json["value"],
    );
  }
}
