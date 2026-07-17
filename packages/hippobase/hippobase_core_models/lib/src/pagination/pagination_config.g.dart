// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pagination_config.dart';

// **************************************************************************
// JsonSchemaBuilderGenerator
// **************************************************************************

// ignore_for_file: unused_element, unused_field
final class _$PaginationConfig implements JsonEncodable {
  const _$PaginationConfig({this.offset = 0, this.limit});

  static const schemaId = 'PaginationConfig';

  static const JsonSchema schema = JsonSchema.object(
    id: schemaId,
    properties: <String, JsonSchema>{
      'offset': JsonSchema.integer(defaultValue: 0),
      'limit': JsonSchema.integer(),
    },
    additionalProperties: false,
  );

  static const schemaRef = JsonSchema.componentRef(schemaId);

  final int offset;

  final int? limit;

  @override
  Map<String, Object?> toJson() {
    return <String, Object?>{"offset": offset, "limit": limit};
  }

  static PaginationConfig decode(Object? value) {
    return fromJson(value as Map<String, Object?>);
  }

  static PaginationConfig fromJson(Map<String, Object?> json) {
    return PaginationConfig(
      offset: json.containsKey("offset") ? json["offset"]! as int : 0,
      limit: json["limit"] as int?,
    );
  }
}
