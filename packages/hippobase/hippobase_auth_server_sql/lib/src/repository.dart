part of 'store.dart';

final class _HippobaseAuthSqlRepository {
  _HippobaseAuthSqlRepository(this.database, {String? schema})
    : users = AuthUsersTable.withSchema(schema),
      sessions = AuthSessionsTable.withSchema(schema),
      accounts = AuthAccountsTable.withSchema(schema),
      verifications = AuthVerificationsTable.withSchema(schema),
      passkeys = AuthPasskeysTable.withSchema(schema);

  final SqlPool database;
  final AuthUsersTable users;
  final AuthSessionsTable sessions;
  final AuthAccountsTable accounts;
  final AuthVerificationsTable verifications;
  final AuthPasskeysTable passkeys;
  final Uuid _uuid = const Uuid();
}
