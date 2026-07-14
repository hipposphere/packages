// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sign_in.dart';

// **************************************************************************
// DartEdgeHttpServerBuilderGenerator
// **************************************************************************

// ignore_for_file: unused_element, unused_field
final class _$HippobaseAuthOAuthSignInParams implements JsonEncodable {
  const _$HippobaseAuthOAuthSignInParams({required this.providerId});

  static const schemaId = 'HippobaseAuthOAuthSignInParams';

  static const JsonSchema schema = JsonSchema.object(
    id: schemaId,
    properties: <String, JsonSchema>{'providerId': JsonSchema.string()},
    required: <String>['providerId'],
    additionalProperties: false,
  );

  static const schemaRef = JsonSchema.componentRef(schemaId);

  static const RequestBody requestBody = RequestBody.json(schema: schema, decoder: decode);

  static const ResponseSpec response = ResponseSpec.json(status: 200, schema: schema);

  final String providerId;

  @override
  Map<String, Object?> toJson() {
    return <String, Object?>{"providerId": providerId};
  }

  static HippobaseAuthOAuthSignInParams decode(Object? value) {
    return fromJson(readJsonObject(value));
  }

  static HippobaseAuthOAuthSignInParams fromJson(Map<String, Object?> json) {
    return HippobaseAuthOAuthSignInParams(providerId: json["providerId"]! as String);
  }
}

final class _$HippobaseAuthOAuthSignInQuery implements JsonEncodable {
  const _$HippobaseAuthOAuthSignInQuery({required this.callbackURL});

  static const schemaId = 'HippobaseAuthOAuthSignInQuery';

  static const JsonSchema schema = JsonSchema.object(
    id: schemaId,
    properties: <String, JsonSchema>{'callbackURL': JsonSchema.string()},
    required: <String>['callbackURL'],
    additionalProperties: true,
  );

  static const schemaRef = JsonSchema.componentRef(schemaId);

  static const RequestBody requestBody = RequestBody.json(schema: schema, decoder: decode);

  static const ResponseSpec response = ResponseSpec.json(status: 200, schema: schema);

  final String callbackURL;

  @override
  Map<String, Object?> toJson() {
    return <String, Object?>{"callbackURL": callbackURL};
  }

  static HippobaseAuthOAuthSignInQuery decode(Object? value) {
    return fromJson(readJsonObject(value));
  }

  static HippobaseAuthOAuthSignInQuery fromJson(Map<String, Object?> json) {
    return HippobaseAuthOAuthSignInQuery(callbackURL: json["callbackURL"]! as String);
  }
}
