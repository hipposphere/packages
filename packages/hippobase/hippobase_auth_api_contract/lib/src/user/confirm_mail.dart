import 'package:dart_edge_core/dart_edge_core.dart';

import '../shared/route_contract.dart';

part 'confirm_mail.g.dart';

const tokenRequestSchema = JsonSchema.object(
  id: 'HippobaseAuthTokenRequest',
  properties: <String, JsonSchema>{'token': JsonSchema.string()},
  required: <String>['token'],
  additionalProperties: false,
);

@FromSchema(tokenRequestSchema)
typedef HippobaseAuthTokenRequest = _$HippobaseAuthTokenRequest;

const hippobaseAuthConfirmMailRoute = HippobaseAuthRouteContract(
  method: HippobaseAuthMethod.post,
  path: '/v1/user/confirm-mail',
  operationId: 'postV1UserConfirmMail',
);
