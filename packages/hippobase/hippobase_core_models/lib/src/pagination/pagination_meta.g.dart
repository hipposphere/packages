// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pagination_meta.dart';

// **************************************************************************
// JsonSchemaBuilderGenerator
// **************************************************************************

// ignore_for_file: unused_element, unused_field
final class _$PaginationMeta implements JsonEncodable {
  const _$PaginationMeta({
    required this.offset,
    required this.limit,
    required this.totalItems,
    required this.hasMore,
    required this.nextOffset,
    required this.previousOffset,
    required this.firstItemIndex,
    required this.lastItemIndex,
  });

  static const schemaId = 'PaginationMeta';

  static const JsonSchema schema = JsonSchema.object(
    id: schemaId,
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

  static const schemaRef = JsonSchema.componentRef(schemaId);

  final int offset;

  final int limit;

  final int totalItems;

  final bool hasMore;

  final int? nextOffset;

  final int? previousOffset;

  final int firstItemIndex;

  final int lastItemIndex;

  @override
  Map<String, Object?> toJson() {
    return <String, Object?>{
      "offset": offset,
      "limit": limit,
      "total_items": totalItems,
      "has_more": hasMore,
      "next_offset": nextOffset,
      "previous_offset": previousOffset,
      "first_item_index": firstItemIndex,
      "last_item_index": lastItemIndex,
    };
  }

  static PaginationMeta decode(Object? value) {
    return fromJson(value as Map<String, Object?>);
  }

  static PaginationMeta fromJson(Map<String, Object?> json) {
    return PaginationMeta(
      offset: json["offset"]! as int,
      limit: json["limit"]! as int,
      totalItems: json["total_items"]! as int,
      hasMore: json["has_more"]! as bool,
      nextOffset: json["next_offset"] as int?,
      previousOffset: json["previous_offset"] as int?,
      firstItemIndex: json["first_item_index"]! as int,
      lastItemIndex: json["last_item_index"]! as int,
    );
  }
}
