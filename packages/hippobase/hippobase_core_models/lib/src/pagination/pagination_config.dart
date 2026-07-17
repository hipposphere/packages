import 'package:json_schema/json_schema.dart';

part 'pagination_config.g.dart';

const paginationConfigSchemaId = 'PaginationConfig';

/// JSON Schema for [PaginationConfig].
const paginationConfigSchema = JsonSchema.object(
  id: paginationConfigSchemaId,
  properties: <String, JsonSchema>{
    'offset': JsonSchema.integer(defaultValue: 0),
    'limit': JsonSchema.integer(),
  },
  additionalProperties: false,
);

/// Offset-based pagination configuration for list endpoints.
///
/// Either clause may be omitted. Endpoints decide whether to apply defaults or
/// permit an unbounded result set.
@FromSchema(paginationConfigSchema)
typedef PaginationConfig = _$PaginationConfig;

PaginationConfig paginationConfig({int offset = 0, int? limit}) {
  if (offset < 0) {
    throw ArgumentError.value(offset, 'offset', 'must not be negative');
  }
  if (limit != null && limit < 1) {
    throw ArgumentError.value(limit, 'limit', 'must be greater than zero');
  }

  return PaginationConfig(offset: offset, limit: limit);
}
