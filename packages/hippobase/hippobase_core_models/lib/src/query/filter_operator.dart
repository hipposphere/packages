import 'package:dart_edge_core/dart_edge_core.dart';

part 'filter_operator.g.dart';

const filterOperatorSchemaId = 'FilterOperator';

/// JSON Schema for [FilterOperator].
const filterOperatorSchema = JsonSchema.string(
  id: filterOperatorSchemaId,
  enumValues: <String>[
    'eq',
    'ne',
    'lt',
    'lte',
    'gt',
    'gte',
    'like',
    'not_like',
    'ilike',
    'not_ilike',
    'starts_with',
    'ends_with',
    'contains',
    'in_list',
    'not_in_list',
    'between',
    'is_null',
    'is_not_null',
  ],
);

/// Operators available for field-level filters.
@FromSchema(filterOperatorSchema)
typedef FilterOperator = _$FilterOperator;

extension FilterOperatorProperties on FilterOperator {
  bool get requiresValue => this != FilterOperator.isNull && this != FilterOperator.isNotNull;

  bool get requiresListValue {
    return this == FilterOperator.inList ||
        this == FilterOperator.notInList ||
        this == FilterOperator.between;
  }

  bool get requiresStringValue {
    return switch (this) {
      FilterOperator.like ||
      FilterOperator.notLike ||
      FilterOperator.ilike ||
      FilterOperator.notIlike ||
      FilterOperator.startsWith ||
      FilterOperator.endsWith ||
      FilterOperator.contains => true,
      _ => false,
    };
  }
}

FilterOperator filterOperatorFromJson(Object? value) {
  if (value is! String) {
    throw const FormatException('Filter operator must be a string.');
  }

  return switch (value.trim()) {
    '=' || '==' => FilterOperator.eq,
    '!=' || '<>' || 'neq' => FilterOperator.ne,
    '<' => FilterOperator.lt,
    '<=' => FilterOperator.lte,
    '>' => FilterOperator.gt,
    '>=' => FilterOperator.gte,
    'in' || 'in_list' || 'in-list' => FilterOperator.inList,
    'notIn' || 'not_in' || 'not-in' || 'not_in_list' || 'not-in-list' => FilterOperator.notInList,
    'not_like' || 'not-like' => FilterOperator.notLike,
    'iLike' => FilterOperator.ilike,
    'not_ilike' || 'not-ilike' => FilterOperator.notIlike,
    'starts_with' || 'starts-with' => FilterOperator.startsWith,
    'ends_with' || 'ends-with' => FilterOperator.endsWith,
    'is_null' || 'is-null' => FilterOperator.isNull,
    'is_not_null' || 'is-not-null' => FilterOperator.isNotNull,
    final wireName => FilterOperator.fromJson(wireName),
  };
}
