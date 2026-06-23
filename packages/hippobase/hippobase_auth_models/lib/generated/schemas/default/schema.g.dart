import 'package:dart_edge_core/dart_edge_core.dart';
import 'tables/account.g.dart';
import 'tables/passkey.g.dart';
import 'tables/session.g.dart';
import 'tables/user.g.dart';
import 'tables/verification.g.dart';
export 'tables/account.g.dart';
export 'tables/passkey.g.dart';
export 'tables/session.g.dart';
export 'tables/user.g.dart';
export 'tables/verification.g.dart';

final class DefaultSchema {
  const DefaultSchema({this.databaseSchema});

  const DefaultSchema._() : databaseSchema = null;

  final String? databaseSchema;

  static const instance = DefaultSchema._();

  static const schemaName = 'default';

  static const account = HippobaseAuthAccountsTable.table;

  static const passkey = HippobaseAuthPasskeysTable.table;

  static const session = HippobaseAuthSessionsTable.table;

  static const user = HippobaseAuthUsersTable.table;

  static const verification = HippobaseAuthVerificationsTable.table;

  static const List<JsonSchema> schemas = <JsonSchema>[
    HippobaseAuthAccountRow.jsonSchema,
    HippobaseAuthAccountInsert.jsonSchema,
    HippobaseAuthAccountUpdate.jsonSchema,
    HippobaseAuthPasskeyRow.jsonSchema,
    HippobaseAuthPasskeyInsert.jsonSchema,
    HippobaseAuthPasskeyUpdate.jsonSchema,
    HippobaseAuthSessionRow.jsonSchema,
    HippobaseAuthSessionInsert.jsonSchema,
    HippobaseAuthSessionUpdate.jsonSchema,
    HippobaseAuthUserRow.jsonSchema,
    HippobaseAuthUserInsert.jsonSchema,
    HippobaseAuthUserUpdate.jsonSchema,
    HippobaseAuthVerificationRow.jsonSchema,
    HippobaseAuthVerificationInsert.jsonSchema,
    HippobaseAuthVerificationUpdate.jsonSchema,
  ];

  static const JsonSchemaRegistry jsonSchemas = JsonSchemaRegistry(schemas: schemas);
}

extension DefaultSchemaTables on DefaultSchema {
  HippobaseAuthAccountsTable get account => HippobaseAuthAccountsTable.withSchema(
    databaseSchema ?? HippobaseAuthAccountsTable.table.schema,
  );

  HippobaseAuthPasskeysTable get passkey => HippobaseAuthPasskeysTable.withSchema(
    databaseSchema ?? HippobaseAuthPasskeysTable.table.schema,
  );

  HippobaseAuthSessionsTable get session => HippobaseAuthSessionsTable.withSchema(
    databaseSchema ?? HippobaseAuthSessionsTable.table.schema,
  );

  HippobaseAuthUsersTable get user =>
      HippobaseAuthUsersTable.withSchema(databaseSchema ?? HippobaseAuthUsersTable.table.schema);

  HippobaseAuthVerificationsTable get verification => HippobaseAuthVerificationsTable.withSchema(
    databaseSchema ?? HippobaseAuthVerificationsTable.table.schema,
  );
}
