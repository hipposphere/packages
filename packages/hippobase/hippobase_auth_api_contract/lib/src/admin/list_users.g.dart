// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'list_users.dart';

// **************************************************************************
// DartEdgeHttpServerBuilderGenerator
// **************************************************************************

// ignore_for_file: unused_element, unused_field
final class _$HippobaseAuthAdminListUsersResponse implements JsonEncodable {
  const _$HippobaseAuthAdminListUsersResponse({required this.items, required this.meta});

  static const schemaId = 'HippobaseAuthAdminListUsersResponse';

  static const JsonSchema schema = JsonSchema.object(
    id: schemaId,
    properties: <String, JsonSchema>{
      'items': JsonSchema.array(items: JsonSchema.ref('#/components/schemas/AuthUserRow')),
      'meta': JsonSchema.ref('#/components/schemas/PaginationMeta'),
    },
    required: <String>['items', 'meta'],
    additionalProperties: false,
  );

  static const schemaRef = JsonSchema.componentRef(schemaId);

  static const RequestBody requestBody = RequestBody.json(schema: schema, decoder: decode);

  static const ResponseSpec response = ResponseSpec.json(status: 200, schema: schema);

  final List<AuthUserRow> items;

  final PaginationMeta meta;

  @override
  Map<String, Object?> toJson() {
    return <String, Object?>{
      "items": items.map((item) => item.toJson()).toList(),
      "meta": meta.toJson(),
    };
  }

  static HippobaseAuthAdminListUsersResponse decode(Object? value) {
    return fromJson(readJsonObject(value));
  }

  static HippobaseAuthAdminListUsersResponse fromJson(Map<String, Object?> json) {
    return HippobaseAuthAdminListUsersResponse(
      items: (json["items"]! as List)
          .map((item) => AuthUserRow.fromJson(Map<String, Object?>.from(item! as Map)))
          .toList(),
      meta: PaginationMeta.decode(json["meta"]),
    );
  }
}
