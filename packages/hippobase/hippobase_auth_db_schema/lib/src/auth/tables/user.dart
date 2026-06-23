import 'package:dart_edge_sql_migrator/dart_edge_sql_migrator.dart';

const SqlTableSchema betterAuthUserTable = SqlTableSchema(
  name: 'user',
  columns: <SqlColumnSchema>[
    SqlColumnSchema(name: 'id', type: 'TEXT', nullable: false, primaryKey: true),
    SqlColumnSchema(name: 'name', type: 'TEXT', nullable: false),
    SqlColumnSchema(name: 'email', type: 'TEXT', nullable: false, unique: true),
    SqlColumnSchema(name: 'emailVerified', type: 'BOOLEAN', nullable: false),
    SqlColumnSchema(name: 'image', type: 'TEXT'),
    SqlColumnSchema(name: 'createdAt', type: 'TIMESTAMPTZ', nullable: false),
    SqlColumnSchema(name: 'updatedAt', type: 'TIMESTAMPTZ', nullable: false),
    SqlColumnSchema(name: 'role', type: 'TEXT'),
    SqlColumnSchema(name: 'banned', type: 'BOOLEAN'),
    SqlColumnSchema(name: 'banReason', type: 'TEXT'),
    SqlColumnSchema(name: 'banExpires', type: 'TIMESTAMPTZ'),
    SqlColumnSchema(name: 'phoneNumber', type: 'TEXT', unique: true),
    SqlColumnSchema(name: 'phoneNumberVerified', type: 'BOOLEAN'),
  ],
);
