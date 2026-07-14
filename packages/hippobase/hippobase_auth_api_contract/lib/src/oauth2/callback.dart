import 'package:dart_edge_core/dart_edge_core.dart';

import '../shared/route_contract.dart';

part 'callback.g.dart';

const oauthCallbackQuerySchema = JsonSchema.object(
  id: 'HippobaseAuthOAuthCallbackQuery',
  properties: <String, JsonSchema>{
    'code': JsonSchema.string(nullable: true),
    'state': JsonSchema.string(nullable: true),
    'error': JsonSchema.string(nullable: true),
    'error_description': JsonSchema.string(nullable: true),
  },
  additionalProperties: true,
);

@FromSchema(oauthCallbackQuerySchema)
typedef HippobaseAuthOAuthCallbackQuery = _$HippobaseAuthOAuthCallbackQuery;

const hippobaseAuthOAuthCallbackRoute = HippobaseAuthRouteContract(
  method: HippobaseAuthMethod.get,
  path: '/v1/oauth2/callback/<providerId>',
  operationId: 'getV1Oauth2CallbackByProviderId',
);
