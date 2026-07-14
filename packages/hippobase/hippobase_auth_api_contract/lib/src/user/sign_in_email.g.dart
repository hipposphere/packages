// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sign_in_email.dart';

// **************************************************************************
// DartEdgeHttpServerBuilderGenerator
// **************************************************************************

// ignore_for_file: unused_element, unused_field
final class _$HippobaseAuthSignInEmailRequest implements JsonEncodable {
  const _$HippobaseAuthSignInEmailRequest({required this.email, required this.password});

  static const schemaId = 'HippobaseAuthSignInEmailRequest';

  static const JsonSchema schema = JsonSchema.object(
    id: schemaId,
    properties: <String, JsonSchema>{
      'email': JsonSchema.string(format: 'email'),
      'password': JsonSchema.string(),
    },
    required: <String>['email', 'password'],
    additionalProperties: false,
  );

  static const schemaRef = JsonSchema.componentRef(schemaId);

  static const RequestBody requestBody = RequestBody.json(schema: schema, decoder: decode);

  static const ResponseSpec response = ResponseSpec.json(status: 200, schema: schema);

  final String email;

  final String password;

  @override
  Map<String, Object?> toJson() {
    return <String, Object?>{"email": email, "password": password};
  }

  static HippobaseAuthSignInEmailRequest decode(Object? value) {
    return fromJson(readJsonObject(value));
  }

  static HippobaseAuthSignInEmailRequest fromJson(Map<String, Object?> json) {
    return HippobaseAuthSignInEmailRequest(
      email: json["email"]! as String,
      password: json["password"]! as String,
    );
  }
}
