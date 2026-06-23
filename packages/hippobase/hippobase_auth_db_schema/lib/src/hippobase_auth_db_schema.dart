import 'package:dart_edge_sql_migrator/dart_edge_sql_migrator.dart';

import 'auth/schema.dart';

const List<SqlTableSchema> hippobaseAuthDbSchemaTables = <SqlTableSchema>[
  ...betterAuthSchemaTables,
];

const SqlDatabaseSchema hippobaseAuthDbSchema = SqlDatabaseSchema(
  tables: hippobaseAuthDbSchemaTables,
);
