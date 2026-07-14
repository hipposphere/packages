import 'package:dart_edge_core/dart_edge_core.dart';
import 'package:hippobase_auth_models/hippobase_auth_models.dart';

import '../shared/route_contract.dart';

part 'get_user.g.dart';

const hippobaseAuthUserResponseSchema = JsonSchema.object(
  id: 'HippobaseAuthUserResponse',
  properties: <String, JsonSchema>{'user': AuthUserRow.schemaRef},
  required: <String>['user'],
  additionalProperties: false,
);

@FromSchema(
  hippobaseAuthUserResponseSchema,
  registry: JsonSchemaRegistry(schemas: <JsonSchema>[AuthUserRow.jsonSchema]),
  refs: <SchemaRefModel>[SchemaRefModel(AuthUserRow)],
)
typedef HippobaseAuthUserResponse = _$HippobaseAuthUserResponse;

const hippobaseAuthGetUserRoute = HippobaseAuthRouteContract(
  method: HippobaseAuthMethod.get,
  path: '/v1/user/get_user',
  operationId: 'getV1UserGetUser',
);
