import 'package:dart_edge_core/dart_edge_core.dart'
    show FromHttpSchema, RequestBody, ResponseSpec, readJsonObject;
import 'package:hippobase_auth_models/hippobase_auth_models.dart';
import 'package:hippobase_core_models/hippobase_core_models.dart';
import 'package:json_schema/json_schema.dart';

import '../shared/route_contract.dart';

part 'list_users.g.dart';

const adminListUsersResponseSchema = JsonSchema.object(
  id: 'HippobaseAuthAdminListUsersResponse',
  properties: <String, JsonSchema>{
    'items': JsonSchema.array(items: AuthUserRow.schemaRef),
    'meta': JsonSchema.componentRef(paginationMetaSchemaId),
  },
  required: <String>['items', 'meta'],
  additionalProperties: false,
);

@FromHttpSchema(
  adminListUsersResponseSchema,
  registry: JsonSchemaRegistry(schemas: <JsonSchema>[AuthUserRow.jsonSchema, paginationMetaSchema]),
  refs: <SchemaRefModel>[SchemaRefModel(AuthUserRow)],
)
typedef HippobaseAuthAdminListUsersResponse = _$HippobaseAuthAdminListUsersResponse;

typedef HippobaseAuthAdminListUsersQuery = PaginationConfig;

const hippobaseAuthAdminListUsersRoute = HippobaseAuthRouteContract(
  method: HippobaseAuthMethod.get,
  path: '/v1/admin/users',
  operationId: 'getV1AdminUsers',
);
