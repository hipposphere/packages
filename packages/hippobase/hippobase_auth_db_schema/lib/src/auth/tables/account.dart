import 'package:dart_edge_sql_migrator/dart_edge_sql_migrator.dart';

const SqlTableSchema betterAuthAccountTable = SqlTableSchema(
  schema: 'auth',
  name: 'account',
  columns: <SqlColumnSchema>[
    SqlColumnSchema(name: 'id', type: 'TEXT', nullable: false, primaryKey: true),
    SqlColumnSchema(name: 'accountId', type: 'TEXT', nullable: false),
    SqlColumnSchema(name: 'providerId', type: 'TEXT', nullable: false),
    SqlColumnSchema(name: 'userId', type: 'TEXT', nullable: false),
    SqlColumnSchema(name: 'accessToken', type: 'TEXT'),
    SqlColumnSchema(name: 'refreshToken', type: 'TEXT'),
    SqlColumnSchema(name: 'idToken', type: 'TEXT'),
    SqlColumnSchema(name: 'accessTokenExpiresAt', type: 'TIMESTAMPTZ'),
    SqlColumnSchema(name: 'refreshTokenExpiresAt', type: 'TIMESTAMPTZ'),
    SqlColumnSchema(name: 'scope', type: 'TEXT'),
    SqlColumnSchema(name: 'password', type: 'TEXT'),
    SqlColumnSchema(name: 'createdAt', type: 'TIMESTAMPTZ', nullable: false),
    SqlColumnSchema(name: 'updatedAt', type: 'TIMESTAMPTZ', nullable: false),
  ],
  foreignKeys: <SqlForeignKeyConstraintSchema>[
    SqlForeignKeyConstraintSchema(
      name: 'account_user_id_fkey',
      columns: <String>['userId'],
      referencesSchema: 'auth',
      referencesTable: 'user',
      referencesColumns: <String>['id'],
      onDelete: SqlForeignKeyAction.cascade,
    ),
  ],
);
