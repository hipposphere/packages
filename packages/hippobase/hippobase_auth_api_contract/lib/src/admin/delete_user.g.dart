// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'delete_user.dart';

// **************************************************************************
// DartEdgeHttpServerBuilderGenerator
// **************************************************************************

// ignore_for_file: unused_element, unused_field
final class _$HippobaseAuthAdminDeleteUserParams implements JsonEncodable {
  const _$HippobaseAuthAdminDeleteUserParams({required this.userId});

  static const schemaId = 'HippobaseAuthAdminDeleteUserParams';

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

  static HippobaseAuthAdminDeleteUserParams decode(Object? value) {
    return fromJson(readJsonObject(value));
  }

  static HippobaseAuthAdminDeleteUserParams fromJson(Map<String, Object?> json) {
    return HippobaseAuthAdminDeleteUserParams(userId: json["userId"]! as String);
  }
}

final class _$HippobaseAuthAdminDeleteUserResponse implements JsonEncodable {
  const _$HippobaseAuthAdminDeleteUserResponse({required this.success, required this.userId});

  static const schemaId = 'HippobaseAuthAdminDeleteUserResponse';

  static const JsonSchema schema = JsonSchema.object(
    id: schemaId,
    properties: <String, JsonSchema>{
      'success': JsonSchema.boolean(),
      'user_id': JsonSchema.string(),
    },
    required: <String>['success', 'user_id'],
    additionalProperties: false,
  );

  static const schemaRef = JsonSchema.componentRef(schemaId);

  static const RequestBody requestBody = RequestBody.json(schema: schema, decoder: decode);

  static const ResponseSpec response = ResponseSpec.json(status: 200, schema: schema);

  final bool success;

  final String userId;

  @override
  Map<String, Object?> toJson() {
    return <String, Object?>{"success": success, "user_id": userId};
  }

  static HippobaseAuthAdminDeleteUserResponse decode(Object? value) {
    return fromJson(readJsonObject(value));
  }

  static HippobaseAuthAdminDeleteUserResponse fromJson(Map<String, Object?> json) {
    return HippobaseAuthAdminDeleteUserResponse(
      success: json["success"]! as bool,
      userId: json["user_id"]! as String,
    );
  }
}
