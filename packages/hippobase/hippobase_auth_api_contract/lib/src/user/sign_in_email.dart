import 'package:dart_edge_core/dart_edge_core.dart'
    show FromHttpSchema, RequestBody, ResponseSpec, readJsonObject;
import 'package:json_schema/json_schema.dart';

import '../shared/route_contract.dart';

part 'sign_in_email.g.dart';

const signInEmailRequestSchema = JsonSchema.object(
  id: 'HippobaseAuthSignInEmailRequest',
  properties: <String, JsonSchema>{
    'email': JsonSchema.string(format: 'email'),
    'password': JsonSchema.string(),
  },
  required: <String>['email', 'password'],
  additionalProperties: false,
);

@FromHttpSchema(signInEmailRequestSchema)
typedef HippobaseAuthSignInEmailRequest = _$HippobaseAuthSignInEmailRequest;

const hippobaseAuthSignInEmailRoute = HippobaseAuthRouteContract(
  method: HippobaseAuthMethod.post,
  path: '/v1/user/sign-in-email',
  operationId: 'postV1UserSignInEmail',
);
