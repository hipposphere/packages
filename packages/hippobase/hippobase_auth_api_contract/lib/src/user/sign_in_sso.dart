import 'package:dart_edge_core/dart_edge_core.dart';

import '../shared/route_contract.dart';

part 'sign_in_sso.g.dart';

const signInSsoRequestSchema = JsonSchema.object(
  id: 'HippobaseAuthSignInSsoRequest',
  properties: <String, JsonSchema>{
    'provider_id': JsonSchema.string(),
    'success_url': JsonSchema.string(),
  },
  required: <String>['provider_id', 'success_url'],
  additionalProperties: false,
);

const signInSsoResponseSchema = JsonSchema.object(
  id: 'HippobaseAuthSignInSsoResponse',
  properties: <String, JsonSchema>{
    'success': JsonSchema.boolean(),
    'data': JsonSchema.object(
      properties: <String, JsonSchema>{
        'providerId': JsonSchema.string(),
        'redirectUrl': JsonSchema.string(),
      },
      required: <String>['providerId', 'redirectUrl'],
      additionalProperties: false,
    ),
  },
  required: <String>['success', 'data'],
  additionalProperties: false,
);

@FromSchema(signInSsoRequestSchema)
typedef HippobaseAuthSignInSsoRequest = _$HippobaseAuthSignInSsoRequest;

@FromSchema(signInSsoResponseSchema)
typedef HippobaseAuthSignInSsoResponse = _$HippobaseAuthSignInSsoResponse;

const hippobaseAuthSignInSsoRoute = HippobaseAuthRouteContract(
  method: HippobaseAuthMethod.post,
  path: '/v1/user/sign-in-sso',
  operationId: 'postV1UserSignInSso',
);
