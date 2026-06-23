import 'package:dart_edge_sql_migrator/dart_edge_sql_migrator.dart';

const SqlTableSchema betterAuthSessionTable = SqlTableSchema(
  name: 'session',
  columns: <SqlColumnSchema>[
    SqlColumnSchema(name: 'id', type: 'TEXT', nullable: false, primaryKey: true),
    SqlColumnSchema(name: 'expiresAt', type: 'TIMESTAMPTZ', nullable: false),
    SqlColumnSchema(name: 'token', type: 'TEXT', nullable: false, unique: true),
    SqlColumnSchema(name: 'createdAt', type: 'TIMESTAMPTZ', nullable: false),
    SqlColumnSchema(name: 'updatedAt', type: 'TIMESTAMPTZ', nullable: false),
    SqlColumnSchema(name: 'ipAddress', type: 'TEXT'),
    SqlColumnSchema(name: 'userAgent', type: 'TEXT'),
    SqlColumnSchema(name: 'userId', type: 'TEXT', nullable: false),
    SqlColumnSchema(name: 'impersonatedBy', type: 'TEXT'),
  ],
  foreignKeys: <SqlForeignKeyConstraintSchema>[
    SqlForeignKeyConstraintSchema(
      name: 'session_user_id_fkey',
      columns: <String>['userId'],
      referencesTable: 'user',
      referencesColumns: <String>['id'],
      onDelete: SqlForeignKeyAction.cascade,
    ),
  ],
);
