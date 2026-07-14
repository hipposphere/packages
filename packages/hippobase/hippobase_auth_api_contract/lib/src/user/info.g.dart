// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'info.dart';

// **************************************************************************
// DartEdgeHttpServerBuilderGenerator
// **************************************************************************

// ignore_for_file: unused_element, unused_field
final class _$HippobaseAuthSsoProvider implements JsonEncodable {
  const _$HippobaseAuthSsoProvider({required this.providerId, required this.providerType});

  static const schemaId = 'HippobaseAuthSsoProvider';

  static const JsonSchema schema = JsonSchema.object(
    id: schemaId,
    properties: <String, JsonSchema>{
      'provider_id': JsonSchema.string(),
      'provider_type': JsonSchema.string(),
    },
    required: <String>['provider_id', 'provider_type'],
    additionalProperties: false,
  );

  static const schemaRef = JsonSchema.componentRef(schemaId);

  static const RequestBody requestBody = RequestBody.json(schema: schema, decoder: decode);

  static const ResponseSpec response = ResponseSpec.json(status: 200, schema: schema);

  final String providerId;

  final String providerType;

  @override
  Map<String, Object?> toJson() {
    return <String, Object?>{"provider_id": providerId, "provider_type": providerType};
  }

  static HippobaseAuthSsoProvider decode(Object? value) {
    return fromJson(readJsonObject(value));
  }

  static HippobaseAuthSsoProvider fromJson(Map<String, Object?> json) {
    return HippobaseAuthSsoProvider(
      providerId: json["provider_id"]! as String,
      providerType: json["provider_type"]! as String,
    );
  }
}

final class _$HippobaseAuthInfoResponse implements JsonEncodable {
  const _$HippobaseAuthInfoResponse({
    required this.emailSignInEnabled,
    required this.emailSignUpEnabled,
    required this.ssoProviders,
  });

  static const schemaId = 'HippobaseAuthInfoResponse';

  static const JsonSchema schema = JsonSchema.object(
    id: schemaId,
    properties: <String, JsonSchema>{
      'email_sign_in_enabled': JsonSchema.boolean(),
      'email_sign_up_enabled': JsonSchema.boolean(),
      'sso_providers': JsonSchema.array(
        items: JsonSchema.object(
          id: 'HippobaseAuthSsoProvider',
          properties: <String, JsonSchema>{
            'provider_id': JsonSchema.string(),
            'provider_type': JsonSchema.string(),
          },
          required: <String>['provider_id', 'provider_type'],
          additionalProperties: false,
        ),
      ),
    },
    required: <String>['email_sign_in_enabled', 'email_sign_up_enabled', 'sso_providers'],
    additionalProperties: false,
  );

  static const schemaRef = JsonSchema.componentRef(schemaId);

  static const RequestBody requestBody = RequestBody.json(schema: schema, decoder: decode);

  static const ResponseSpec response = ResponseSpec.json(status: 200, schema: schema);

  final bool emailSignInEnabled;

  final bool emailSignUpEnabled;

  final List<Map<String, Object?>> ssoProviders;

  @override
  Map<String, Object?> toJson() {
    return <String, Object?>{
      "email_sign_in_enabled": emailSignInEnabled,
      "email_sign_up_enabled": emailSignUpEnabled,
      "sso_providers": ssoProviders.map((item) => item).toList(),
    };
  }

  static HippobaseAuthInfoResponse decode(Object? value) {
    return fromJson(readJsonObject(value));
  }

  static HippobaseAuthInfoResponse fromJson(Map<String, Object?> json) {
    return HippobaseAuthInfoResponse(
      emailSignInEnabled: json["email_sign_in_enabled"]! as bool,
      emailSignUpEnabled: json["email_sign_up_enabled"]! as bool,
      ssoProviders: (json["sso_providers"]! as List)
          .map(
            (item) => <String, Object?>{
              "provider_id": (Map<String, Object?>.from(item! as Map))["provider_id"]! as String,
              "provider_type":
                  (Map<String, Object?>.from(item! as Map))["provider_type"]! as String,
            },
          )
          .toList(),
    );
  }
}
