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

final class AuthSchema {
  const AuthSchema({this.databaseSchema});

  const AuthSchema._() : databaseSchema = null;

  final String? databaseSchema;

  static const instance = AuthSchema._();

  static const schemaName = 'auth';

  static const account = AuthAccountsTable.table;

  static const passkey = AuthPasskeysTable.table;

  static const session = AuthSessionsTable.table;

  static const user = AuthUsersTable.table;

  static const verification = AuthVerificationsTable.table;

  static const List<JsonSchema> schemas = <JsonSchema>[
    AuthAccountRow.jsonSchema,
    AuthAccountInsert.jsonSchema,
    AuthAccountUpdate.jsonSchema,
    AuthPasskeyRow.jsonSchema,
    AuthPasskeyInsert.jsonSchema,
    AuthPasskeyUpdate.jsonSchema,
    AuthSessionRow.jsonSchema,
    AuthSessionInsert.jsonSchema,
    AuthSessionUpdate.jsonSchema,
    AuthUserRow.jsonSchema,
    AuthUserInsert.jsonSchema,
    AuthUserUpdate.jsonSchema,
    AuthVerificationRow.jsonSchema,
    AuthVerificationInsert.jsonSchema,
    AuthVerificationUpdate.jsonSchema,
  ];

  static const JsonSchemaRegistry jsonSchemas = JsonSchemaRegistry(
    schemas: schemas,
  );
}

extension AuthSchemaTables on AuthSchema {
  AuthAccountsTable get account => AuthAccountsTable.withSchema(
    databaseSchema ?? AuthAccountsTable.table.schema,
  );

  AuthPasskeysTable get passkey => AuthPasskeysTable.withSchema(
    databaseSchema ?? AuthPasskeysTable.table.schema,
  );

  AuthSessionsTable get session => AuthSessionsTable.withSchema(
    databaseSchema ?? AuthSessionsTable.table.schema,
  );

  AuthUsersTable get user =>
      AuthUsersTable.withSchema(databaseSchema ?? AuthUsersTable.table.schema);

  AuthVerificationsTable get verification => AuthVerificationsTable.withSchema(
    databaseSchema ?? AuthVerificationsTable.table.schema,
  );
}
