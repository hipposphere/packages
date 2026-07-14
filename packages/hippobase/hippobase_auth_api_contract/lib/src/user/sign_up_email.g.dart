// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sign_up_email.dart';

// **************************************************************************
// DartEdgeHttpServerBuilderGenerator
// **************************************************************************

// ignore_for_file: unused_element, unused_field
final class _$HippobaseAuthSignUpEmailRequest implements JsonEncodable {
  const _$HippobaseAuthSignUpEmailRequest({
    required this.email,
    required this.password,
    required this.name,
  });

  static const schemaId = 'HippobaseAuthSignUpEmailRequest';

  static const JsonSchema schema = JsonSchema.object(
    id: schemaId,
    properties: <String, JsonSchema>{
      'email': JsonSchema.string(format: 'email'),
      'password': JsonSchema.string(),
      'name': JsonSchema.string(),
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

  @override
  Map<String, Object?> toJson() {
    return <String, Object?>{"email": email, "password": password, "name": name};
  }

  static HippobaseAuthSignUpEmailRequest decode(Object? value) {
    return fromJson(readJsonObject(value));
  }

  static HippobaseAuthSignUpEmailRequest fromJson(Map<String, Object?> json) {
    return HippobaseAuthSignUpEmailRequest(
      email: json["email"]! as String,
      password: json["password"]! as String,
      name: json["name"]! as String,
    );
  }
}

final class _$HippobaseAuthSessionPayload implements JsonEncodable {
  const _$HippobaseAuthSessionPayload({
    required this.sessionId,
    required this.token,
    required this.expiresAt,
    required this.user,
  });

  static const schemaId = 'HippobaseAuthSessionPayload';

  static const JsonSchema schema = JsonSchema.object(
    id: schemaId,
    properties: <String, JsonSchema>{
      'session_id': JsonSchema.string(),
      'token': JsonSchema.string(),
      'expires_at': JsonSchema.string(format: 'date-time'),
      'user': JsonSchema.ref('#/components/schemas/AuthUserRow'),
    },
    required: <String>['session_id', 'token', 'expires_at', 'user'],
    additionalProperties: false,
  );

  static const schemaRef = JsonSchema.componentRef(schemaId);

  static const RequestBody requestBody = RequestBody.json(schema: schema, decoder: decode);

  static const ResponseSpec response = ResponseSpec.json(status: 200, schema: schema);

  final String sessionId;

  final String token;

  final DateTime expiresAt;

  final AuthUserRow user;

  @override
  Map<String, Object?> toJson() {
    return <String, Object?>{
      "session_id": sessionId,
      "token": token,
      "expires_at": expiresAt.toIso8601String(),
      "user": user.toJson(),
    };
  }

  static HippobaseAuthSessionPayload decode(Object? value) {
    return fromJson(readJsonObject(value));
  }

  static HippobaseAuthSessionPayload fromJson(Map<String, Object?> json) {
    return HippobaseAuthSessionPayload(
      sessionId: json["session_id"]! as String,
      token: json["token"]! as String,
      expiresAt: DateTime.parse(json["expires_at"]! as String),
      user: AuthUserRow.fromJson(Map<String, Object?>.from(json["user"]! as Map)),
    );
  }
}
