import 'package:dart_edge_core/dart_edge_core.dart';

import '../pagination/pagination_config.dart';
import 'filter_group.dart';
import 'sort_term.dart';

part 'list_query.g.dart';

const listQuerySchemaId = 'ListQuery';

/// JSON Schema for [ListQuery].
const listQuerySchema = JsonSchema.object(
  id: listQuerySchemaId,
  properties: <String, JsonSchema>{
    'pagination': JsonSchema.componentRef(paginationConfigSchemaId),
    'sort': JsonSchema.array(items: JsonSchema.componentRef(sortTermSchemaId)),
    'filter': JsonSchema.componentRef(filterGroupSchemaId),
  },
  required: <String>['pagination', 'sort'],
  additionalProperties: false,
);

/// A generic list query with pagination, sorting, and an optional filter tree.
@FromSchema(listQuerySchema)
typedef ListQuery = _$ListQuery;

extension ListQueryProperties on ListQuery {
  ListQuery withoutFilter() {
    return ListQuery(pagination: pagination, sort: sort);
  }
}
