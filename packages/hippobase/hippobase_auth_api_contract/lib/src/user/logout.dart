import 'package:dart_edge_core/dart_edge_core.dart';
import 'package:hippobase_auth_models/hippobase_auth_models.dart';

import '../shared/route_contract.dart';

part 'logout.g.dart';

const hippobaseAuthLogoutResponseSchema = JsonSchema.object(
  id: 'HippobaseAuthLogoutResponse',
  properties: <String, JsonSchema>{'user': AuthUserRow.schemaRef},
  required: <String>['user'],
  additionalProperties: false,
);

@FromSchema(
  hippobaseAuthLogoutResponseSchema,
  registry: JsonSchemaRegistry(schemas: <JsonSchema>[AuthUserRow.jsonSchema]),
  refs: <SchemaRefModel>[SchemaRefModel(AuthUserRow)],
)
typedef HippobaseAuthLogoutResponse = _$HippobaseAuthLogoutResponse;

const hippobaseAuthLogoutRoute = HippobaseAuthRouteContract(
  method: HippobaseAuthMethod.get,
  path: '/v1/user/logout',
  operationId: 'getV1UserLogout',
);
