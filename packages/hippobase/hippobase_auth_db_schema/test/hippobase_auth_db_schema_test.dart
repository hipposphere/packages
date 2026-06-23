import 'package:dart_edge_sql/dart_edge_sql.dart';
import 'package:dart_edge_sql_migrator/dart_edge_sql_migrator.dart';
import 'package:hippobase_auth_db_schema/hippobase_auth_db_schema.dart';
import 'package:test/test.dart';

void main() {
  test('contains Better Auth core tables in dependency order', () {
    expect(hippobaseAuthDbSchemaTables.map((table) => table.name), [
      'user',
      'session',
      'account',
      'verification',
      'passkey',
    ]);
    expect(hippobaseAuthDbSchemaTables.map((table) => table.schema), everyElement('auth'));
  });

  test('renders cascade foreign keys for user-owned tables', () {
    final statements =
        SqlSchemaDiff.between(
              current: const SqlDatabaseSchema(tables: <SqlTableSchema>[]),
              desired: hippobaseAuthDbSchema,
            )
            .toMigrationPlan()
            .forDialect(SqlDialect.postgres)
            .map((statement) => statement.sql)
            .join('\n');

    expect(statements, contains('CONSTRAINT "session_user_id_fkey"'));
    expect(statements, contains('REFERENCES "auth"."user" ("id") ON DELETE CASCADE'));
    expect(statements, contains('CONSTRAINT "account_user_id_fkey"'));
    expect(statements, contains('CONSTRAINT "passkey_user_id_fkey"'));
  });
}
