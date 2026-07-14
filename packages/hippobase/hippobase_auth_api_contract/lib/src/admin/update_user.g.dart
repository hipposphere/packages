// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'update_user.dart';

// **************************************************************************
// DartEdgeHttpServerBuilderGenerator
// **************************************************************************

// ignore_for_file: unused_element, unused_field
final class _$HippobaseAuthAdminUpdateUserParams implements JsonEncodable {
  const _$HippobaseAuthAdminUpdateUserParams({required this.userId});

  static const schemaId = 'HippobaseAuthAdminUpdateUserParams';

  static const JsonSchema schema = JsonSchema.object(
    id: schemaId,
    properties: <String, JsonSchema>{'userId': JsonSchema.string()},
    required: <String>['userId'],
    additionalProperties: false,
  );

  static const schemaRef = JsonSchema.componentRef(schemaId);

  static const RequestBody requestBody = RequestBody.json(schema: schema, decoder: decode);

  static const ResponseSpec response = ResponseSpec.json(status: 200, schema: schema);

  final String userId;

  @override
  Map<String, Object?> toJson() {
    return <String, Object?>{"userId": userId};
  }

  static HippobaseAuthAdminUpdateUserParams decode(Object? value) {
    return fromJson(readJsonObject(value));
  }

  static HippobaseAuthAdminUpdateUserParams fromJson(Map<String, Object?> json) {
    return HippobaseAuthAdminUpdateUserParams(userId: json["userId"]! as String);
  }
}

final class _$HippobaseAuthAdminUpdateUserRequest implements JsonEncodable {
  const _$HippobaseAuthAdminUpdateUserRequest({required this.role});

  static const schemaId = 'HippobaseAuthAdminUpdateUserRequest';

  static const JsonSchema schema = JsonSchema.object(
    id: schemaId,
    properties: <String, JsonSchema>{'role': JsonSchema.string()},
    required: <String>['role'],
    additionalProperties: false,
  );

  static const schemaRef = JsonSchema.componentRef(schemaId);

  static const RequestBody requestBody = RequestBody.json(schema: schema, decoder: decode);

  static const ResponseSpec response = ResponseSpec.json(status: 200, schema: schema);

  final String role;

  @override
  Map<String, Object?> toJson() {
    return <String, Object?>{"role": role};
  }

  static HippobaseAuthAdminUpdateUserRequest decode(Object? value) {
    return fromJson(readJsonObject(value));
  }

  static HippobaseAuthAdminUpdateUserRequest fromJson(Map<String, Object?> json) {
    return HippobaseAuthAdminUpdateUserRequest(role: json["role"]! as String);
  }
}
