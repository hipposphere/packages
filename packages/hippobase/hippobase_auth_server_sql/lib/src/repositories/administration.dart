part of '../store.dart';

extension _HippobaseAuthAdministrationRepository on _HippobaseAuthSqlRepository {
  Future<List<AuthUserRow>> listUsers({required int limit, required int offset}) {
    return database.typed
        .from(users)
        .selectTable(users)
        .orderBy(AuthUsersTable.createdAt.desc())
        .limit(limit)
        .offset(offset)
        .execute();
  }

  Future<int> countUsers() => database.typed.from(users).executeCount();

  Future<AuthUserRow?> updateRole(AuthUserId userId, String role) {
    return database.typed
        .updateTable(users)
        .set(AuthUserUpdate(role: SqlValue(role), updatedAt: SqlValue(DateTime.now().toUtc())))
        .where(AuthUsersTable.id.equals(userId))
        .executeReturningFirstOrNull();
  }

  Future<bool> deleteUser(AuthUserId userId) {
    return database.withTransaction((transaction) async {
      await transaction.typed
          .deleteFrom(sessions)
          .where(AuthSessionsTable.userId.equals(userId))
          .execute();
      await transaction.typed
          .deleteFrom(passkeys)
          .where(AuthPasskeysTable.userId.equals(userId))
          .execute();
      await transaction.typed
          .deleteFrom(accounts)
          .where(AuthAccountsTable.userId.equals(userId))
          .execute();
      await transaction.typed
          .deleteFrom(verifications)
          .where(AuthVerificationsTable.value.equals(userId.value))
          .execute();
      final deleted = await transaction.typed
          .deleteFrom(users)
          .where(AuthUsersTable.id.equals(userId))
          .executeReturningFirstOrNull();
      return deleted != null;
    });
  }
}
