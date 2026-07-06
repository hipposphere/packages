// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'paginated_response.dart';

// **************************************************************************
// DartEdgeHttpServerBuilderGenerator
// **************************************************************************

// ignore_for_file: unused_element, unused_field
final class _$PaginatedResponse implements JsonEncodable {
  const _$PaginatedResponse({required this.items, required this.meta});

  static const schemaId = 'PaginatedResponse';

  static const JsonSchema schema = JsonSchema.object(
    id: schemaId,
    properties: <String, JsonSchema>{
      'items': JsonSchema.array(items: JsonSchema.any()),
      'meta': JsonSchema.ref('#/components/schemas/PaginationMeta'),
    },
    required: <String>['items', 'meta'],
    additionalProperties: false,
  );

  static const schemaRef = JsonSchema.componentRef(schemaId);

  static const RequestBody requestBody = RequestBody.json(schema: schema, decoder: decode);

  static const ResponseSpec response = ResponseSpec.json(status: 200, schema: schema);

  final List<Object?> items;

  final PaginationMeta meta;

  @override
  Map<String, Object?> toJson() {
    return <String, Object?>{"items": items.map((item) => item).toList(), "meta": meta.toJson()};
  }

  static PaginatedResponse decode(Object? value) {
    return fromJson(readJsonObject(value));
  }

  static PaginatedResponse fromJson(Map<String, Object?> json) {
    return PaginatedResponse(
      items: (json["items"]! as List).map((item) => item).toList(),
      meta: PaginationMeta.decode(json["meta"]),
    );
  }
}
