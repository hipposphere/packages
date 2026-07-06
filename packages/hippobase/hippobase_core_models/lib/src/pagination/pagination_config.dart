import 'package:dart_edge_core/dart_edge_core.dart';

part 'pagination_config.g.dart';

const paginationConfigSchemaId = 'PaginationConfig';

/// JSON Schema for [PaginationConfig].
const paginationConfigSchema = JsonSchema.object(
  id: paginationConfigSchemaId,
  properties: <String, JsonSchema>{'offset': JsonSchema.integer(), 'limit': JsonSchema.integer()},
  required: <String>['offset', 'limit'],
  additionalProperties: false,
);

/// Offset-based pagination configuration for list endpoints.
@FromSchema(paginationConfigSchema)
typedef PaginationConfig = _$PaginationConfig;

PaginationConfig paginationConfig({int offset = 0, int limit = 50}) {
  if (offset < 0) {
    throw ArgumentError.value(offset, 'offset', 'must not be negative');
  }
  if (limit < 1) {
    throw ArgumentError.value(limit, 'limit', 'must be greater than zero');
  }

  return PaginationConfig(offset: offset, limit: limit);
}
