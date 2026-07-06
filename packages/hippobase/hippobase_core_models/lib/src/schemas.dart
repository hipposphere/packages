import 'package:dart_edge_core/dart_edge_core.dart';

import 'pagination/paginated_response.dart';
import 'pagination/pagination_meta.dart';
import 'pagination/pagination_config.dart';
import 'query/field_filter.dart';
import 'query/filter_combinator.dart';
import 'query/filter_group.dart';
import 'query/filter_operator.dart';
import 'query/list_query.dart';
import 'query/sort_term.dart';

const hippobaseCoreModelsSchemas = <JsonSchema>[
  paginationConfigSchema,
  paginationMetaSchema,
  paginatedResponseSchema,
  sortDirectionSchema,
  sortTermSchema,
  filterOperatorSchema,
  filterCombinatorSchema,
  fieldFilterSchema,
  filterGroupSchema,
  listQuerySchema,
];

const hippobaseCoreJsonSchemas = JsonSchemaRegistry(schemas: hippobaseCoreModelsSchemas);
