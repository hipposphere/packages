// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sign_in_sso.dart';

// **************************************************************************
// DartEdgeHttpServerBuilderGenerator
// **************************************************************************

// ignore_for_file: unused_element, unused_field
final class _$HippobaseAuthSignInSsoRequest implements JsonEncodable {
  const _$HippobaseAuthSignInSsoRequest({required this.providerId, required this.successUrl});

  static const schemaId = 'HippobaseAuthSignInSsoRequest';

  static const JsonSchema schema = JsonSchema.object(
    id: schemaId,
    properties: <String, JsonSchema>{
      'provider_id': JsonSchema.string(),
      'success_url': JsonSchema.string(),
    },
    required: <String>['provider_id', 'success_url'],
    additionalProperties: false,
  );

  static const schemaRef = JsonSchema.componentRef(schemaId);

  static const RequestBody requestBody = RequestBody.json(schema: schema, decoder: decode);

  static const ResponseSpec response = ResponseSpec.json(status: 200, schema: schema);

  final String providerId;

  final String successUrl;

  @override
  Map<String, Object?> toJson() {
    return <String, Object?>{"provider_id": providerId, "success_url": successUrl};
  }

  static HippobaseAuthSignInSsoRequest decode(Object? value) {
    return fromJson(readJsonObject(value));
  }

  static HippobaseAuthSignInSsoRequest fromJson(Map<String, Object?> json) {
    return HippobaseAuthSignInSsoRequest(
      providerId: json["provider_id"]! as String,
      successUrl: json["success_url"]! as String,
    );
  }
}

final class _$HippobaseAuthSignInSsoResponse implements JsonEncodable {
  const _$HippobaseAuthSignInSsoResponse({required this.success, required this.data});

  static const schemaId = 'HippobaseAuthSignInSsoResponse';

  static const JsonSchema schema = JsonSchema.object(
    id: schemaId,
    properties: <String, JsonSchema>{
      'success': JsonSchema.boolean(),
      'data': JsonSchema.object(
        properties: <String, JsonSchema>{
          'providerId': JsonSchema.string(),
          'redirectUrl': JsonSchema.string(),
        },
        required: <String>['providerId', 'redirectUrl'],
        additionalProperties: false,
      ),
    },
    required: <String>['success', 'data'],
    additionalProperties: false,
  );

  static const schemaRef = JsonSchema.componentRef(schemaId);

  static const RequestBody requestBody = RequestBody.json(schema: schema, decoder: decode);

  static const ResponseSpec response = ResponseSpec.json(status: 200, schema: schema);

  final bool success;

  final Map<String, Object?> data;

  @override
  Map<String, Object?> toJson() {
    return <String, Object?>{"success": success, "data": data};
  }

  static HippobaseAuthSignInSsoResponse decode(Object? value) {
    return fromJson(readJsonObject(value));
  }

  static HippobaseAuthSignInSsoResponse fromJson(Map<String, Object?> json) {
    return HippobaseAuthSignInSsoResponse(
      success: json["success"]! as bool,
      data: <String, Object?>{
        "providerId": (Map<String, Object?>.from(json["data"]! as Map))["providerId"]! as String,
        "redirectUrl": (Map<String, Object?>.from(json["data"]! as Map))["redirectUrl"]! as String,
      },
    );
  }
}
