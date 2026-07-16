import 'package:dart_edge_core/dart_edge_core.dart'
    show FromHttpSchema, RequestBody, ResponseSpec, readJsonObject;
import 'package:json_schema/json_schema.dart';

import '../shared/route_contract.dart';
import '../user/get_user.dart';

part 'update_user.g.dart';

const adminUpdateUserParamsSchema = JsonSchema.object(
  id: 'HippobaseAuthAdminUpdateUserParams',
  properties: <String, JsonSchema>{'userId': JsonSchema.string()},
  required: <String>['userId'],
  additionalProperties: false,
);

const adminUpdateUserRequestSchema = JsonSchema.object(
  id: 'HippobaseAuthAdminUpdateUserRequest',
  properties: <String, JsonSchema>{'role': JsonSchema.string()},
  required: <String>['role'],
  additionalProperties: false,
);

@FromHttpSchema(adminUpdateUserParamsSchema)
typedef HippobaseAuthAdminUpdateUserParams = _$HippobaseAuthAdminUpdateUserParams;

@FromHttpSchema(adminUpdateUserRequestSchema)
typedef HippobaseAuthAdminUpdateUserRequest = _$HippobaseAuthAdminUpdateUserRequest;

typedef HippobaseAuthAdminUpdateUserResponse = HippobaseAuthUserResponse;

const hippobaseAuthAdminUpdateUserRoute = HippobaseAuthRouteContract(
  method: HippobaseAuthMethod.patch,
  path: '/v1/admin/users/<userId>',
  operationId: 'patchV1AdminUsersByUserId',
);
