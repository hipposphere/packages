// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'request_password_reset.dart';

// **************************************************************************
// DartEdgeHttpServerBuilderGenerator
// **************************************************************************

// ignore_for_file: unused_element, unused_field
final class _$HippobaseAuthEmailRequest implements JsonEncodable {
  const _$HippobaseAuthEmailRequest({required this.email});

  static const schemaId = 'HippobaseAuthEmailRequest';

  static const JsonSchema schema = JsonSchema.object(
    id: schemaId,
    properties: <String, JsonSchema>{'email': JsonSchema.string(format: 'email')},
    required: <String>['email'],
    additionalProperties: false,
  );

  static const schemaRef = JsonSchema.componentRef(schemaId);

  static const RequestBody requestBody = RequestBody.json(schema: schema, decoder: decode);

  static const ResponseSpec response = ResponseSpec.json(status: 200, schema: schema);

  final String email;

  @override
  Map<String, Object?> toJson() {
    return <String, Object?>{"email": email};
  }

  static HippobaseAuthEmailRequest decode(Object? value) {
    return fromJson(readJsonObject(value));
  }

  static HippobaseAuthEmailRequest fromJson(Map<String, Object?> json) {
    return HippobaseAuthEmailRequest(email: json["email"]! as String);
  }
}

final class _$HippobaseAuthSuccessResponse implements JsonEncodable {
  const _$HippobaseAuthSuccessResponse({required this.success});

  static const schemaId = 'HippobaseAuthSuccessResponse';

  static const JsonSchema schema = JsonSchema.object(
    id: schemaId,
    properties: <String, JsonSchema>{'success': JsonSchema.boolean()},
    required: <String>['success'],
    additionalProperties: false,
  );

  static const schemaRef = JsonSchema.componentRef(schemaId);

  static const RequestBody requestBody = RequestBody.json(schema: schema, decoder: decode);

  static const ResponseSpec response = ResponseSpec.json(status: 200, schema: schema);

  final bool success;

  @override
  Map<String, Object?> toJson() {
    return <String, Object?>{"success": success};
  }

  static HippobaseAuthSuccessResponse decode(Object? value) {
    return fromJson(readJsonObject(value));
  }

  static HippobaseAuthSuccessResponse fromJson(Map<String, Object?> json) {
    return HippobaseAuthSuccessResponse(success: json["success"]! as bool);
  }
}
