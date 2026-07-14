import 'package:dart_edge_core/dart_edge_core.dart';

import '../shared/route_contract.dart';

part 'info.g.dart';

const hippobaseAuthSsoProviderSchema = JsonSchema.object(
  id: 'HippobaseAuthSsoProvider',
  properties: <String, JsonSchema>{
    'provider_id': JsonSchema.string(),
    'provider_type': JsonSchema.string(),
  },
  required: <String>['provider_id', 'provider_type'],
  additionalProperties: false,
);

const hippobaseAuthInfoResponseSchema = JsonSchema.object(
  id: 'HippobaseAuthInfoResponse',
  properties: <String, JsonSchema>{
    'email_sign_in_enabled': JsonSchema.boolean(),
    'email_sign_up_enabled': JsonSchema.boolean(),
    'sso_providers': JsonSchema.array(items: hippobaseAuthSsoProviderSchema),
  },
  required: <String>['email_sign_in_enabled', 'email_sign_up_enabled', 'sso_providers'],
  additionalProperties: false,
);

@FromSchema(hippobaseAuthSsoProviderSchema)
typedef HippobaseAuthSsoProvider = _$HippobaseAuthSsoProvider;

@FromSchema(hippobaseAuthInfoResponseSchema)
typedef HippobaseAuthInfoResponse = _$HippobaseAuthInfoResponse;

const hippobaseAuthInfoRoute = HippobaseAuthRouteContract(
  method: HippobaseAuthMethod.get,
  path: '/v1/user/info',
  operationId: 'getV1UserInfo',
);
