import 'package:dart_edge_core/dart_edge_core.dart';
import 'package:json_schema/json_schema.dart';
import 'schemas/auth/schema.g.dart';
export 'schemas/auth/schema.g.dart';

final class AuthDatabase {
  const AuthDatabase._();

  static const authSchema = AuthSchema.instance;

  static const List<SqlKeyManifestEntry> sqlKeyManifest = <SqlKeyManifestEntry>[
    AuthAccountId.manifest,
    AuthPasskeyId.manifest,
    AuthSessionId.manifest,
    AuthUserId.manifest,
    AuthVerificationId.manifest,
  ];

  static const List<JsonSchema> schemas = <JsonSchema>[...AuthSchema.schemas];

  static const JsonSchemaRegistry jsonSchemas = JsonSchemaRegistry(schemas: schemas);
}
