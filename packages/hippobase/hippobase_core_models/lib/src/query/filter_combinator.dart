import 'package:dart_edge_core/dart_edge_core.dart';

part 'filter_combinator.g.dart';

const filterCombinatorSchemaId = 'FilterCombinator';

/// JSON Schema for [FilterCombinator].
const filterCombinatorSchema = JsonSchema.string(
  id: filterCombinatorSchemaId,
  enumValues: <String>['and', 'or'],
);

/// Boolean combinator for grouped filter expressions.
@FromSchema(filterCombinatorSchema)
typedef FilterCombinator = _$FilterCombinator;
