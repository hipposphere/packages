import 'package:dart_edge_core/dart_edge_core.dart';

import '../shared/route_contract.dart';

part 'refresh_session.g.dart';

const refreshSessionResponseSchema = JsonSchema.object(
  id: 'HippobaseAuthRefreshSessionResponse',
  properties: <String, JsonSchema>{'expires_at': JsonSchema.string(format: 'date-time')},
  required: <String>['expires_at'],
  additionalProperties: false,
);

@FromSchema(refreshSessionResponseSchema)
typedef HippobaseAuthRefreshSessionResponse = _$HippobaseAuthRefreshSessionResponse;

const hippobaseAuthRefreshSessionRoute = HippobaseAuthRouteContract(
  method: HippobaseAuthMethod.post,
  path: '/v1/user/refresh-session',
  operationId: 'postV1UserRefreshSession',
);
