// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'error.dart';

// **************************************************************************
// DartEdgeHttpServerBuilderGenerator
// **************************************************************************

// ignore_for_file: unused_element, unused_field
final class _$HippobaseAuthError implements JsonEncodable {
  const _$HippobaseAuthError({required this.error});

  static const schemaId = 'HippobaseAuthError';

  static const JsonSchema schema = JsonSchema.object(
    id: schemaId,
    properties: <String, JsonSchema>{
      'error': JsonSchema.object(
        properties: <String, JsonSchema>{
          'code': JsonSchema.string(),
          'message': JsonSchema.string(),
          'details': JsonSchema.object(nullable: true, additionalProperties: true),
        },
        required: <String>['code', 'message'],
        additionalProperties: false,
      ),
    },
    required: <String>['error'],
    additionalProperties: false,
  );

  static const schemaRef = JsonSchema.componentRef(schemaId);

  static const RequestBody requestBody = RequestBody.json(schema: schema, decoder: decode);

  static const ResponseSpec response = ResponseSpec.json(status: 200, schema: schema);

  final Map<String, Object?> error;

  @override
  Map<String, Object?> toJson() {
    return <String, Object?>{"error": error};
  }

  static HippobaseAuthError decode(Object? value) {
    return fromJson(readJsonObject(value));
  }

  static HippobaseAuthError fromJson(Map<String, Object?> json) {
    return HippobaseAuthError(
      error: <String, Object?>{
        "code": (Map<String, Object?>.from(json["error"]! as Map))["code"]! as String,
        "message": (Map<String, Object?>.from(json["error"]! as Map))["message"]! as String,
        "details": (Map<String, Object?>.from(json["error"]! as Map))["details"] == null
            ? null
            : Map<String, Object?>.from(
                (Map<String, Object?>.from(json["error"]! as Map))["details"] as Map,
              ),
      },
    );
  }
}
