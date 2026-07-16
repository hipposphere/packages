import 'package:dart_edge_core/dart_edge_core.dart'
    show FromHttpSchema, RequestBody, ResponseSpec, readJsonObject;
import 'package:json_schema/json_schema.dart';

import '../shared/route_contract.dart';

part 'delete_user.g.dart';

const adminDeleteUserParamsSchema = JsonSchema.object(
  id: 'HippobaseAuthAdminDeleteUserParams',
  properties: <String, JsonSchema>{'userId': JsonSchema.string()},
  required: <String>['userId'],
  additionalProperties: false,
);

const adminDeleteUserResponseSchema = JsonSchema.object(
  id: 'HippobaseAuthAdminDeleteUserResponse',
  properties: <String, JsonSchema>{'success': JsonSchema.boolean(), 'user_id': JsonSchema.string()},
  required: <String>['success', 'user_id'],
  additionalProperties: false,
);

@FromHttpSchema(adminDeleteUserParamsSchema)
typedef HippobaseAuthAdminDeleteUserParams = _$HippobaseAuthAdminDeleteUserParams;

@FromHttpSchema(adminDeleteUserResponseSchema)
typedef HippobaseAuthAdminDeleteUserResponse = _$HippobaseAuthAdminDeleteUserResponse;

const hippobaseAuthAdminDeleteUserRoute = HippobaseAuthRouteContract(
  method: HippobaseAuthMethod.delete,
  path: '/v1/admin/users/<userId>',
  operationId: 'deleteV1AdminUsersByUserId',
);
