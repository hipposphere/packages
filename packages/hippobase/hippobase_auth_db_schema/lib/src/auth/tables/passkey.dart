import 'package:dart_edge_sql_migrator/dart_edge_sql_migrator.dart';

const SqlTableSchema betterAuthPasskeyTable = SqlTableSchema(
  schema: 'auth',
  name: 'passkey',
  columns: <SqlColumnSchema>[
    SqlColumnSchema(name: 'id', type: 'TEXT', nullable: false, primaryKey: true),
    SqlColumnSchema(name: 'name', type: 'TEXT'),
    SqlColumnSchema(name: 'publicKey', type: 'TEXT', nullable: false),
    SqlColumnSchema(name: 'userId', type: 'TEXT', nullable: false),
    SqlColumnSchema(name: 'credentialID', type: 'TEXT', nullable: false),
    SqlColumnSchema(name: 'counter', type: 'INTEGER', nullable: false),
    SqlColumnSchema(name: 'deviceType', type: 'TEXT', nullable: false),
    SqlColumnSchema(name: 'backedUp', type: 'BOOLEAN', nullable: false),
    SqlColumnSchema(name: 'transports', type: 'TEXT'),
    SqlColumnSchema(name: 'createdAt', type: 'TIMESTAMPTZ'),
    SqlColumnSchema(name: 'aaguid', type: 'TEXT'),
  ],
  foreignKeys: <SqlForeignKeyConstraintSchema>[
    SqlForeignKeyConstraintSchema(
      name: 'passkey_user_id_fkey',
      columns: <String>['userId'],
      referencesSchema: 'auth',
      referencesTable: 'user',
      referencesColumns: <String>['id'],
      onDelete: SqlForeignKeyAction.cascade,
    ),
  ],
);
