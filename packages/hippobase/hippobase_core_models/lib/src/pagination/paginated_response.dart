import 'package:dart_edge_core/dart_edge_core.dart';

import 'pagination_meta.dart';

part 'paginated_response.g.dart';

const paginatedResponseSchemaId = 'PaginatedResponse';

/// JSON Schema for [PaginatedResponse].
const paginatedResponseSchema = JsonSchema.object(
  id: paginatedResponseSchemaId,
  properties: <String, JsonSchema>{
    'items': JsonSchema.array(items: JsonSchema.any()),
    'meta': JsonSchema.componentRef(paginationMetaSchemaId),
  },
  required: <String>['items', 'meta'],
  additionalProperties: false,
);

/// A page of items plus pagination metadata.
@FromSchema(paginatedResponseSchema)
typedef PaginatedResponse = _$PaginatedResponse;
