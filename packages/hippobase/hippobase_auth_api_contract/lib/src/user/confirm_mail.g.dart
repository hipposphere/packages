// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'confirm_mail.dart';

// **************************************************************************
// DartEdgeHttpServerBuilderGenerator
// **************************************************************************

// ignore_for_file: unused_element, unused_field
final class _$HippobaseAuthTokenRequest implements JsonEncodable {
  const _$HippobaseAuthTokenRequest({required this.token});

  static const schemaId = 'HippobaseAuthTokenRequest';

  static const JsonSchema schema = JsonSchema.object(
    id: schemaId,
    properties: <String, JsonSchema>{'token': JsonSchema.string()},
    required: <String>['token'],
    additionalProperties: false,
  );

  static const schemaRef = JsonSchema.componentRef(schemaId);

  static const RequestBody requestBody = RequestBody.json(schema: schema, decoder: decode);

  static const ResponseSpec response = ResponseSpec.json(status: 200, schema: schema);

  final String token;

  @override
  Map<String, Object?> toJson() {
    return <String, Object?>{"token": token};
  }

  static HippobaseAuthTokenRequest decode(Object? value) {
    return fromJson(readJsonObject(value));
  }

  static HippobaseAuthTokenRequest fromJson(Map<String, Object?> json) {
    return HippobaseAuthTokenRequest(token: json["token"]! as String);
  }
}
