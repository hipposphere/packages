import 'package:dart_edge_core/dart_edge_core.dart';

import '../../generated/auth_database.g.dart';

const hippobaseAuthModelsSchemas = <JsonSchema>[...AuthDatabase.schemas];

const hippobaseAuthJsonSchemas = JsonSchemaRegistry(schemas: hippobaseAuthModelsSchemas);
