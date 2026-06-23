import 'dart:developer' as developer;
import 'dart:io';

import 'package:dart_edge_sql/dart_edge_sql.dart';
import 'package:dart_edge_sql_codegen/dart_edge_sql_codegen.dart';
import 'package:dart_edge_sql_migrator/dart_edge_sql_migrator.dart';
import 'package:dart_edge_sql_pglite/dart_edge_sql_pglite.dart';
import 'package:hippobase_auth_db_schema/hippobase_auth_db_schema.dart';

Future<void> main() async {
  final packageRoot = File.fromUri(Platform.script).parent.parent;
  final database = PgliteDatabase.temporary().asPostgresPool();

  Object? bodyError;
  StackTrace? bodyStackTrace;

  try {
    _log('Applying Hippobase auth schema.');
    final diff = SqlSchemaDiff.between(
      current: const SqlDatabaseSchema(tables: <SqlTableSchema>[]),
      desired: hippobaseAuthDbSchema,
    );
    final plan = diff.toMigrationPlan();
    for (final statement in plan.byDialect[SqlDialect.postgres] ?? const <SqlStatement>[]) {
      await database.execute(statement);
    }

    _log('Introspecting database schema.');
    final introspection = await PostgresIntrospector.fromDatabase(database).introspect();

    _log('Emitting Dart schema.');
    final emission = emitDartSchema(
      _withoutDefaultSchema(introspection),
      databaseClassName: 'HippobaseAuthDatabase',
      naming: DartSchemaNaming(modelNameBuilder: _authModelName),
      primaryKeyExtensionTypes: false,
    );
    emission.writeToDirectory('${packageRoot.path}/lib/generated');
    _log('Wrote generated schema.');
  } catch (error, stackTrace) {
    bodyError = error;
    bodyStackTrace = stackTrace;
    _log('Generation failed before cleanup: $error');
  } finally {
    _log('Closing temporary database.');
    try {
      await database.close();
      _log('Closed temporary database.');
    } catch (error, stackTrace) {
      if (bodyError != null) {
        _log('Cleanup also failed: $error');
      } else {
        Error.throwWithStackTrace(error, stackTrace);
      }
    }
  }

  if (bodyError != null) {
    Error.throwWithStackTrace(bodyError, bodyStackTrace!);
  }
}

IntrospectedDatabase _withoutDefaultSchema(IntrospectedDatabase database) {
  return IntrospectedDatabase(
    dialect: database.dialect,
    tables: [
      for (final table in database.tables)
        IntrospectedTable(name: table.name, columns: table.columns, constraints: table.constraints),
    ],
    enums: database.enums,
    routines: database.routines,
  );
}

String _authModelName(DartSchemaModelNameContext context) {
  final tablePrefix = switch (context.tableName) {
    'user' => 'HippobaseAuthUser',
    'session' => 'HippobaseAuthSession',
    'account' => 'HippobaseAuthAccount',
    'verification' => 'HippobaseAuthVerification',
    'passkey' => 'HippobaseAuthPasskey',
    final table => throw StateError('Unsupported Better Auth table "$table".'),
  };
  return switch (context.kind) {
    DartSchemaModelKind.row => '${tablePrefix}Row',
    DartSchemaModelKind.insert => '${tablePrefix}Insert',
    DartSchemaModelKind.update => '${tablePrefix}Update',
    DartSchemaModelKind.table => '${tablePrefix}sTable',
  };
}

void _log(String message) {
  developer.log(message, name: 'generate_models');
  stderr.writeln('[generate_models] $message');
}
