import 'package:dart_edge_core/dart_edge_core.dart'
    show FromHttpSchema, RequestBody, ResponseSpec, readJsonObject;
import 'package:json_schema/json_schema.dart';

import '../shared/route_contract.dart';

part 'sign_in.g.dart';

const oauthSignInParamsSchema = JsonSchema.object(
  id: 'HippobaseAuthOAuthSignInParams',
  properties: <String, JsonSchema>{'providerId': JsonSchema.string()},
  required: <String>['providerId'],
  additionalProperties: false,
);

const oauthSignInQuerySchema = JsonSchema.object(
  id: 'HippobaseAuthOAuthSignInQuery',
  properties: <String, JsonSchema>{'callbackURL': JsonSchema.string()},
  required: <String>['callbackURL'],
  additionalProperties: true,
);

@FromHttpSchema(oauthSignInParamsSchema)
typedef HippobaseAuthOAuthSignInParams = _$HippobaseAuthOAuthSignInParams;

@FromHttpSchema(oauthSignInQuerySchema)
typedef HippobaseAuthOAuthSignInQuery = _$HippobaseAuthOAuthSignInQuery;

const hippobaseAuthOAuthSignInRoute = HippobaseAuthRouteContract(
  method: HippobaseAuthMethod.get,
  path: '/v1/oauth2/sign-in/<providerId>',
  operationId: 'getV1Oauth2SignInByProviderId',
);
