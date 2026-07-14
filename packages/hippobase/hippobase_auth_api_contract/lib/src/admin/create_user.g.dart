// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'create_user.dart';

// **************************************************************************
// DartEdgeHttpServerBuilderGenerator
// **************************************************************************

// ignore_for_file: unused_element, unused_field
final class _$HippobaseAuthAdminCreateUserRequest implements JsonEncodable {
  const _$HippobaseAuthAdminCreateUserRequest({
    required this.email,
    required this.password,
    required this.name,
    this.role,
    this.emailVerified,
  });

  static const schemaId = 'HippobaseAuthAdminCreateUserRequest';

  static const JsonSchema schema = JsonSchema.object(
    id: schemaId,
    properties: <String, JsonSchema>{
      'email': JsonSchema.string(format: 'email'),
      'password': JsonSchema.string(),
      'name': JsonSchema.string(),
      'role': JsonSchema.string(nullable: true),
      'email_verified': JsonSchema.boolean(),
    },
    required: <String>['email', 'password', 'name'],
    additionalProperties: false,
  );

  static const schemaRef = JsonSchema.componentRef(schemaId);

  static const RequestBody requestBody = RequestBody.json(schema: schema, decoder: decode);

  static const ResponseSpec response = ResponseSpec.json(status: 200, schema: schema);

  final String email;

  final String password;

  final String name;

  final String? role;

  final bool? emailVerified;

  @override
  Map<String, Object?> toJson() {
    return <String, Object?>{
      "email": email,
      "password": password,
      "name": name,
      "role": role,
      "email_verified": emailVerified,
    };
  }

  static HippobaseAuthAdminCreateUserRequest decode(Object? value) {
    return fromJson(readJsonObject(value));
  }

  static HippobaseAuthAdminCreateUserRequest fromJson(Map<String, Object?> json) {
    return HippobaseAuthAdminCreateUserRequest(
      email: json["email"]! as String,
      password: json["password"]! as String,
      name: json["name"]! as String,
      role: json["role"] as String?,
      emailVerified: json["email_verified"] as bool?,
    );
  }
}
