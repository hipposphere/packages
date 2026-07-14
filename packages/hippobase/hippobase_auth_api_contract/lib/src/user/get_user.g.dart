// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'get_user.dart';

// **************************************************************************
// DartEdgeHttpServerBuilderGenerator
// **************************************************************************

// ignore_for_file: unused_element, unused_field
final class _$HippobaseAuthUserResponse implements JsonEncodable {
  const _$HippobaseAuthUserResponse({required this.user});

  static const schemaId = 'HippobaseAuthUserResponse';

  static const JsonSchema schema = JsonSchema.object(
    id: schemaId,
    properties: <String, JsonSchema>{'user': JsonSchema.ref('#/components/schemas/AuthUserRow')},
    required: <String>['user'],
    additionalProperties: false,
  );

  static const schemaRef = JsonSchema.componentRef(schemaId);

  static const RequestBody requestBody = RequestBody.json(schema: schema, decoder: decode);

  static const ResponseSpec response = ResponseSpec.json(status: 200, schema: schema);

  final AuthUserRow user;

  @override
  Map<String, Object?> toJson() {
    return <String, Object?>{"user": user.toJson()};
  }

  static HippobaseAuthUserResponse decode(Object? value) {
    return fromJson(readJsonObject(value));
  }

  static HippobaseAuthUserResponse fromJson(Map<String, Object?> json) {
    return HippobaseAuthUserResponse(
      user: AuthUserRow.fromJson(Map<String, Object?>.from(json["user"]! as Map)),
    );
  }
}
