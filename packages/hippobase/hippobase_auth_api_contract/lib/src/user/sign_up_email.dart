import 'package:dart_edge_core/dart_edge_core.dart'
    show FromHttpSchema, RequestBody, ResponseSpec, readJsonObject;
import 'package:hippobase_auth_models/hippobase_auth_models.dart';
import 'package:json_schema/json_schema.dart';

import '../shared/route_contract.dart';

part 'sign_up_email.g.dart';

const signUpEmailRequestSchema = JsonSchema.object(
  id: 'HippobaseAuthSignUpEmailRequest',
  properties: <String, JsonSchema>{
    'email': JsonSchema.string(format: 'email'),
    'password': JsonSchema.string(),
    'name': JsonSchema.string(),
  },
  required: <String>['email', 'password', 'name'],
  additionalProperties: false,
);

const hippobaseAuthSessionPayloadSchema = JsonSchema.object(
  id: 'HippobaseAuthSessionPayload',
  properties: <String, JsonSchema>{
    'session_id': JsonSchema.string(),
    'token': JsonSchema.string(),
    'expires_at': JsonSchema.string(format: 'date-time'),
    'user': AuthUserRow.schemaRef,
  },
  required: <String>['session_id', 'token', 'expires_at', 'user'],
  additionalProperties: false,
);

@FromHttpSchema(signUpEmailRequestSchema)
typedef HippobaseAuthSignUpEmailRequest = _$HippobaseAuthSignUpEmailRequest;

@FromHttpSchema(
  hippobaseAuthSessionPayloadSchema,
  registry: JsonSchemaRegistry(schemas: <JsonSchema>[AuthUserRow.jsonSchema]),
  refs: <SchemaRefModel>[SchemaRefModel(AuthUserRow)],
)
typedef HippobaseAuthSessionPayload = _$HippobaseAuthSessionPayload;

const hippobaseAuthSignUpEmailRoute = HippobaseAuthRouteContract(
  method: HippobaseAuthMethod.post,
  path: '/v1/user/sign-up-email',
  operationId: 'postV1UserSignUpEmail',
);
