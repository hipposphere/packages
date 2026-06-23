import 'package:dart_edge_sql_migrator/dart_edge_sql_migrator.dart';

import 'tables/account.dart';
import 'tables/passkey.dart';
import 'tables/session.dart';
import 'tables/user.dart';
import 'tables/verification.dart';

export 'tables/account.dart';
export 'tables/passkey.dart';
export 'tables/session.dart';
export 'tables/user.dart';
export 'tables/verification.dart';

const List<SqlTableSchema> betterAuthSchemaTables = <SqlTableSchema>[
  betterAuthUserTable,
  betterAuthSessionTable,
  betterAuthAccountTable,
  betterAuthVerificationTable,
  betterAuthPasskeyTable,
];

const SqlDatabaseSchema betterAuthSchema = SqlDatabaseSchema(tables: betterAuthSchemaTables);
