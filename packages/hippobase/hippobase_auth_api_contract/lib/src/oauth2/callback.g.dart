// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'callback.dart';

// **************************************************************************
// DartEdgeHttpServerBuilderGenerator
// **************************************************************************

// ignore_for_file: unused_element, unused_field
final class _$HippobaseAuthOAuthCallbackQuery implements JsonEncodable {
  const _$HippobaseAuthOAuthCallbackQuery({
    this.code,
    this.state,
    this.error,
    this.errorDescription,
  });

  static const schemaId = 'HippobaseAuthOAuthCallbackQuery';

  static const JsonSchema schema = JsonSchema.object(
    id: schemaId,
    properties: <String, JsonSchema>{
      'code': JsonSchema.string(nullable: true),
      'state': JsonSchema.string(nullable: true),
      'error': JsonSchema.string(nullable: true),
      'error_description': JsonSchema.string(nullable: true),
    },
    additionalProperties: true,
  );

  static const schemaRef = JsonSchema.componentRef(schemaId);

  static const RequestBody requestBody = RequestBody.json(schema: schema, decoder: decode);

  static const ResponseSpec response = ResponseSpec.json(status: 200, schema: schema);

  final String? code;

  final String? state;

  final String? error;

  final String? errorDescription;

  @override
  Map<String, Object?> toJson() {
    return <String, Object?>{
      "code": code,
      "state": state,
      "error": error,
      "error_description": errorDescription,
    };
  }

  static HippobaseAuthOAuthCallbackQuery decode(Object? value) {
    return fromJson(readJsonObject(value));
  }

  static HippobaseAuthOAuthCallbackQuery fromJson(Map<String, Object?> json) {
    return HippobaseAuthOAuthCallbackQuery(
      code: json["code"] as String?,
      state: json["state"] as String?,
      error: json["error"] as String?,
      errorDescription: json["error_description"] as String?,
    );
  }
}
