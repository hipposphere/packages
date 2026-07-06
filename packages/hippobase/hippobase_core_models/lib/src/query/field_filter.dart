import 'package:dart_edge_core/dart_edge_core.dart';

import 'filter_operator.dart';

part 'field_filter.g.dart';

const fieldFilterSchemaId = 'FieldFilter';

/// JSON Schema for [FieldFilter].
const fieldFilterSchema = JsonSchema.object(
  id: fieldFilterSchemaId,
  properties: <String, JsonSchema>{
    'field': JsonSchema.string(),
    'operator': JsonSchema.componentRef(filterOperatorSchemaId),
    'value': JsonSchema.any(),
  },
  required: <String>['field', 'operator'],
  additionalProperties: false,
);

/// A filter condition applied to one exposed query field.
@FromSchema(fieldFilterSchema)
typedef FieldFilter = _$FieldFilter;

extension FieldFilterProperties on FieldFilter {
  FilterOperator get operator => operatorValue;
}

FieldFilter fieldFilter(String field, FilterOperator operator, [Object? value]) {
  final normalizedValue = _normalizeJsonValue(value);
  _validateFieldFilter(field, operator, normalizedValue);

  return FieldFilter(field: field, operatorValue: operator, value: normalizedValue);
}

void _validateFieldFilter(String field, FilterOperator operator, Object? value) {
  if (field.isEmpty) {
    throw ArgumentError.value(field, 'field', 'must not be empty');
  }

  if (!operator.requiresValue) {
    if (value != null) {
      throw ArgumentError.value(value, 'value', '${operator.toJson()} does not accept a value');
    }
    return;
  }

  if (value == null) {
    throw ArgumentError.value(value, 'value', '${operator.toJson()} requires a value');
  }

  if (operator.requiresStringValue && value is! String) {
    throw ArgumentError.value(value, 'value', '${operator.toJson()} requires a string value');
  }

  if (operator == FilterOperator.between) {
    if (value is! List || value.length != 2) {
      throw ArgumentError.value(value, 'value', 'between requires a two-item list');
    }
    return;
  }

  if (operator.requiresListValue && value is! List) {
    throw ArgumentError.value(value, 'value', '${operator.toJson()} requires a list value');
  }
}

Object? _normalizeJsonValue(Object? value) {
  if (value == null || value is String || value is bool || value is int) {
    return value;
  }

  if (value is double) {
    if (!value.isFinite) {
      throw ArgumentError.value(value, 'value', 'must be finite');
    }
    return value;
  }

  if (value is List) {
    return List<Object?>.unmodifiable(value.map(_normalizeJsonValue));
  }

  if (value is Map) {
    return Map<String, Object?>.unmodifiable(
      value.map((key, value) {
        if (key is! String) {
          throw ArgumentError.value(key, 'key', 'JSON object keys must be strings');
        }
        return MapEntry<String, Object?>(key, _normalizeJsonValue(value));
      }),
    );
  }

  throw ArgumentError.value(value, 'value', 'must be JSON encodable');
}
