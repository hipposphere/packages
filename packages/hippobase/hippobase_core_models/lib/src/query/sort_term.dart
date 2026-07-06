import 'package:dart_edge_core/dart_edge_core.dart';

part 'sort_term.g.dart';

const sortDirectionSchemaId = 'SortDirection';
const sortTermSchemaId = 'SortTerm';

/// JSON Schema for [SortDirection].
const sortDirectionSchema = JsonSchema.string(
  id: sortDirectionSchemaId,
  enumValues: <String>['asc', 'desc'],
);

/// Sort direction for a list query field.
@FromSchema(sortDirectionSchema)
typedef SortDirection = _$SortDirection;

/// JSON Schema for [SortTerm].
const sortTermSchema = JsonSchema.object(
  id: sortTermSchemaId,
  properties: <String, JsonSchema>{
    'field': JsonSchema.string(),
    'direction': JsonSchema.componentRef(sortDirectionSchemaId),
  },
  required: <String>['field', 'direction'],
  additionalProperties: false,
);

/// A field and direction used to order list endpoint results.
@FromSchema(sortTermSchema)
typedef SortTerm = _$SortTerm;

SortDirection sortDirectionFromJson(Object? value) {
  if (value is! String) {
    throw const FormatException('Sort direction must be a string.');
  }

  return switch (value.trim()) {
    'ascending' => SortDirection.asc,
    'descending' => SortDirection.desc,
    final wireName => SortDirection.fromJson(wireName),
  };
}
