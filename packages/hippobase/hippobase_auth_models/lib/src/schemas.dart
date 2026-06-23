import 'package:dart_edge_core/dart_edge_core.dart';

import '../generated/hippobase_auth_database.g.dart';

const hippobaseAuthModelsSchemas = <JsonSchema>[...HippobaseAuthDatabase.schemas];

const hippobaseAuthJsonSchemas = JsonSchemaRegistry(schemas: hippobaseAuthModelsSchemas);
