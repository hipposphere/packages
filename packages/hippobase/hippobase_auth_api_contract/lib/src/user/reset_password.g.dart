// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'reset_password.dart';

// **************************************************************************
// DartEdgeHttpServerBuilderGenerator
// **************************************************************************

// ignore_for_file: unused_element, unused_field
final class _$HippobaseAuthResetPasswordRequest implements JsonEncodable {
  const _$HippobaseAuthResetPasswordRequest({required this.token, required this.newPassword});

  static const schemaId = 'HippobaseAuthResetPasswordRequest';

  static const JsonSchema schema = JsonSchema.object(
    id: schemaId,
    properties: <String, JsonSchema>{
      'token': JsonSchema.string(),
      'new_password': JsonSchema.string(),
    },
    required: <String>['token', 'new_password'],
    additionalProperties: false,
  );

  static const schemaRef = JsonSchema.componentRef(schemaId);

  static const RequestBody requestBody = RequestBody.json(schema: schema, decoder: decode);

  static const ResponseSpec response = ResponseSpec.json(status: 200, schema: schema);

  final String token;

  final String newPassword;

  @override
  Map<String, Object?> toJson() {
    return <String, Object?>{"token": token, "new_password": newPassword};
  }

  static HippobaseAuthResetPasswordRequest decode(Object? value) {
    return fromJson(readJsonObject(value));
  }

  static HippobaseAuthResetPasswordRequest fromJson(Map<String, Object?> json) {
    return HippobaseAuthResetPasswordRequest(
      token: json["token"]! as String,
      newPassword: json["new_password"]! as String,
    );
  }
}
