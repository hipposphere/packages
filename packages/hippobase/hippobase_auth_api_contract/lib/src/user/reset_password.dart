import 'package:dart_edge_core/dart_edge_core.dart';

import '../shared/route_contract.dart';

part 'reset_password.g.dart';

const resetPasswordRequestSchema = JsonSchema.object(
  id: 'HippobaseAuthResetPasswordRequest',
  properties: <String, JsonSchema>{
    'token': JsonSchema.string(),
    'new_password': JsonSchema.string(),
  },
  required: <String>['token', 'new_password'],
  additionalProperties: false,
);

@FromSchema(resetPasswordRequestSchema)
typedef HippobaseAuthResetPasswordRequest = _$HippobaseAuthResetPasswordRequest;

const hippobaseAuthResetPasswordRoute = HippobaseAuthRouteContract(
  method: HippobaseAuthMethod.post,
  path: '/v1/user/reset-password',
  operationId: 'postV1UserResetPassword',
);
