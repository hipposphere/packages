import 'package:dart_edge_core/dart_edge_core.dart';

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

@FromSchema(oauthSignInParamsSchema)
typedef HippobaseAuthOAuthSignInParams = _$HippobaseAuthOAuthSignInParams;

@FromSchema(oauthSignInQuerySchema)
typedef HippobaseAuthOAuthSignInQuery = _$HippobaseAuthOAuthSignInQuery;

const hippobaseAuthOAuthSignInRoute = HippobaseAuthRouteContract(
  method: HippobaseAuthMethod.get,
  path: '/v1/oauth2/sign-in/<providerId>',
  operationId: 'getV1Oauth2SignInByProviderId',
);
