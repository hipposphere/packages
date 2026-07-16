import 'package:dart_edge_core/dart_edge_core.dart'
    show FromHttpSchema, RequestBody, ResponseSpec, readJsonObject;
import 'package:json_schema/json_schema.dart';

part 'error.g.dart';

const hippobaseAuthErrorSchema = JsonSchema.object(
  id: 'HippobaseAuthError',
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

@FromHttpSchema(hippobaseAuthErrorSchema)
typedef HippobaseAuthError = _$HippobaseAuthError;
