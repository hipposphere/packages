import 'package:dart_edge_sql_migrator/dart_edge_sql_migrator.dart';

const SqlTableSchema betterAuthVerificationTable = SqlTableSchema(
  name: 'verification',
  columns: <SqlColumnSchema>[
    SqlColumnSchema(name: 'id', type: 'TEXT', nullable: false, primaryKey: true),
    SqlColumnSchema(name: 'identifier', type: 'TEXT', nullable: false),
    SqlColumnSchema(name: 'value', type: 'TEXT', nullable: false),
    SqlColumnSchema(name: 'expiresAt', type: 'TIMESTAMPTZ', nullable: false),
    SqlColumnSchema(name: 'createdAt', type: 'TIMESTAMPTZ', nullable: false),
    SqlColumnSchema(name: 'updatedAt', type: 'TIMESTAMPTZ', nullable: false),
  ],
);
