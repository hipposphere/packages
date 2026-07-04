import 'package:dart_edge_core/dart_edge_core.dart';
import 'schemas/auth/schema.g.dart';
export 'schemas/auth/schema.g.dart';

final class AuthDatabase {
  const AuthDatabase._();

  static const authSchema = AuthSchema.instance;

  static const List<JsonSchema> schemas = <JsonSchema>[...AuthSchema.schemas];

  static const JsonSchemaRegistry jsonSchemas = JsonSchemaRegistry(
    schemas: schemas,
  );
}
