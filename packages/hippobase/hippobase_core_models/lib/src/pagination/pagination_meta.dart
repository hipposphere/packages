import 'package:json_schema/json_schema.dart';

import 'pagination_config.dart';

part 'pagination_meta.g.dart';

const paginationMetaSchemaId = 'PaginationMeta';

/// JSON Schema for [PaginationMeta].
const paginationMetaSchema = JsonSchema.object(
  id: paginationMetaSchemaId,
  properties: <String, JsonSchema>{
    'offset': JsonSchema.integer(),
    'limit': JsonSchema.integer(),
    'total_items': JsonSchema.integer(),
    'has_more': JsonSchema.boolean(),
    'next_offset': JsonSchema.integer(nullable: true),
    'previous_offset': JsonSchema.integer(nullable: true),
    'first_item_index': JsonSchema.integer(),
    'last_item_index': JsonSchema.integer(),
  },
  required: <String>[
    'offset',
    'limit',
    'total_items',
    'has_more',
    'next_offset',
    'previous_offset',
    'first_item_index',
    'last_item_index',
  ],
  additionalProperties: false,
);

/// Pagination metadata returned with a page of items.
@FromSchema(paginationMetaSchema)
typedef PaginationMeta = _$PaginationMeta;

PaginationMeta paginationMetaFromConfig({
  required PaginationConfig config,
  required int totalItems,
}) {
  final offset = config.offset;
  final limit = config.limit;
  if (limit == null) {
    throw ArgumentError.value(limit, 'config.limit', 'is required for pagination metadata');
  }
  if (offset < 0) {
    throw ArgumentError.value(offset, 'config.offset', 'must not be negative');
  }
  if (limit < 1) {
    throw ArgumentError.value(limit, 'config.limit', 'must be greater than zero');
  }
  if (totalItems < 0) {
    throw ArgumentError.value(totalItems, 'totalItems', 'cannot be negative');
  }

  final nextOffsetCandidate = offset + limit;
  final hasMore = nextOffsetCandidate < totalItems;
  final firstItemIndex = totalItems == 0 || offset >= totalItems ? 0 : offset + 1;
  final candidateLastItemIndex = offset + limit;
  final lastItemIndex = candidateLastItemIndex > totalItems ? totalItems : candidateLastItemIndex;
  final previousOffset = offset == 0 ? null : (offset - limit).clamp(0, totalItems);

  return PaginationMeta(
    offset: offset,
    limit: limit,
    totalItems: totalItems,
    hasMore: hasMore,
    nextOffset: hasMore ? nextOffsetCandidate : null,
    previousOffset: previousOffset,
    firstItemIndex: firstItemIndex,
    lastItemIndex: lastItemIndex,
  );
}
