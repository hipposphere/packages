import 'package:json_schema/json_schema.dart';

import '../../generated/auth_database.g.dart';

const hippobaseAuthModelsSchemas = <JsonSchema>[...AuthDatabase.schemas];

const hippobaseAuthJsonSchemas = JsonSchemaRegistry(schemas: hippobaseAuthModelsSchemas);
