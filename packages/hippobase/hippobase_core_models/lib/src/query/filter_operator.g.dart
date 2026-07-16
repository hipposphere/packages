// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'filter_operator.dart';

// **************************************************************************
// JsonSchemaBuilderGenerator
// **************************************************************************

// ignore_for_file: unused_element, unused_field
enum _$FilterOperator implements JsonEncodable {
  eq('eq'),
  ne('ne'),
  lt('lt'),
  lte('lte'),
  gt('gt'),
  gte('gte'),
  like('like'),
  notLike('not_like'),
  ilike('ilike'),
  notIlike('not_ilike'),
  startsWith('starts_with'),
  endsWith('ends_with'),
  contains('contains'),
  inList('in_list'),
  notInList('not_in_list'),
  between('between'),
  isNull('is_null'),
  isNotNull('is_not_null');

  const _$FilterOperator(this.value);

  final String value;

  static const schemaId = 'FilterOperator';

  static const JsonSchema schema = JsonSchema.string(
    id: schemaId,
    enumValues: [
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

  static const schemaRef = JsonSchema.componentRef(schemaId);

  @override
  String toJson() => value;

  static FilterOperator decode(Object? value) {
    return fromJson(value);
  }

  static FilterOperator fromJson(Object? value) {
    return switch (value) {
      "eq" => FilterOperator.eq,
      "ne" => FilterOperator.ne,
      "lt" => FilterOperator.lt,
      "lte" => FilterOperator.lte,
      "gt" => FilterOperator.gt,
      "gte" => FilterOperator.gte,
      "like" => FilterOperator.like,
      "not_like" => FilterOperator.notLike,
      "ilike" => FilterOperator.ilike,
      "not_ilike" => FilterOperator.notIlike,
      "starts_with" => FilterOperator.startsWith,
      "ends_with" => FilterOperator.endsWith,
      "contains" => FilterOperator.contains,
      "in_list" => FilterOperator.inList,
      "not_in_list" => FilterOperator.notInList,
      "between" => FilterOperator.between,
      "is_null" => FilterOperator.isNull,
      "is_not_null" => FilterOperator.isNotNull,
      _ => throw ArgumentError.value(value, 'value', 'Expected FilterOperator JSON enum value.'),
    };
  }
}
