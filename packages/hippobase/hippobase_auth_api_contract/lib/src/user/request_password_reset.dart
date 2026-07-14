import 'package:dart_edge_core/dart_edge_core.dart';

import '../shared/route_contract.dart';

part 'request_password_reset.g.dart';

const emailRequestSchema = JsonSchema.object(
  id: 'HippobaseAuthEmailRequest',
  properties: <String, JsonSchema>{'email': JsonSchema.string(format: 'email')},
  required: <String>['email'],
  additionalProperties: false,
);

const successResponseSchema = JsonSchema.object(
  id: 'HippobaseAuthSuccessResponse',
  properties: <String, JsonSchema>{'success': JsonSchema.boolean()},
  required: <String>['success'],
  additionalProperties: false,
);

@FromSchema(emailRequestSchema)
typedef HippobaseAuthEmailRequest = _$HippobaseAuthEmailRequest;

@FromSchema(successResponseSchema)
typedef HippobaseAuthSuccessResponse = _$HippobaseAuthSuccessResponse;

const hippobaseAuthRequestPasswordResetRoute = HippobaseAuthRouteContract(
  method: HippobaseAuthMethod.post,
  path: '/v1/user/request-password-reset',
  operationId: 'postV1UserRequestPasswordReset',
);
