import 'package:dart_edge_core/dart_edge_core.dart';

import '../shared/route_contract.dart';
import '../user/get_user.dart';

part 'create_user.g.dart';

const adminCreateUserRequestSchema = JsonSchema.object(
  id: 'HippobaseAuthAdminCreateUserRequest',
  properties: <String, JsonSchema>{
    'email': JsonSchema.string(format: 'email'),
    'password': JsonSchema.string(),
    'name': JsonSchema.string(),
    'role': JsonSchema.string(nullable: true),
    'email_verified': JsonSchema.boolean(),
  },
  required: <String>['email', 'password', 'name'],
  additionalProperties: false,
);

@FromSchema(adminCreateUserRequestSchema)
typedef HippobaseAuthAdminCreateUserRequest = _$HippobaseAuthAdminCreateUserRequest;

typedef HippobaseAuthAdminCreateUserResponse = HippobaseAuthUserResponse;

const hippobaseAuthAdminCreateUserRoute = HippobaseAuthRouteContract(
  method: HippobaseAuthMethod.post,
  path: '/v1/admin/users',
  operationId: 'postV1AdminUsers',
);
