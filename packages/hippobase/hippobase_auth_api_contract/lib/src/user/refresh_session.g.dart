// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'refresh_session.dart';

// **************************************************************************
// DartEdgeHttpServerBuilderGenerator
// **************************************************************************

// ignore_for_file: unused_element, unused_field
final class _$HippobaseAuthRefreshSessionResponse implements JsonEncodable {
  const _$HippobaseAuthRefreshSessionResponse({required this.expiresAt});

  static const schemaId = 'HippobaseAuthRefreshSessionResponse';

  static const JsonSchema schema = JsonSchema.object(
    id: schemaId,
    properties: <String, JsonSchema>{'expires_at': JsonSchema.string(format: 'date-time')},
    required: <String>['expires_at'],
    additionalProperties: false,
  );

  static const schemaRef = JsonSchema.componentRef(schemaId);

  static const RequestBody requestBody = RequestBody.json(schema: schema, decoder: decode);

  static const ResponseSpec response = ResponseSpec.json(status: 200, schema: schema);

  final DateTime expiresAt;

  @override
  Map<String, Object?> toJson() {
    return <String, Object?>{"expires_at": expiresAt.toIso8601String()};
  }

  static HippobaseAuthRefreshSessionResponse decode(Object? value) {
    return fromJson(readJsonObject(value));
  }

  static HippobaseAuthRefreshSessionResponse fromJson(Map<String, Object?> json) {
    return HippobaseAuthRefreshSessionResponse(
      expiresAt: DateTime.parse(json["expires_at"]! as String),
    );
  }
}
