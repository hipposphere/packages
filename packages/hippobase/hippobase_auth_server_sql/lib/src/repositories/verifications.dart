part of '../store.dart';

extension _HippobaseAuthVerificationRepository on _HippobaseAuthSqlRepository {
  Future<String> createOneTimeToken({
    required String purpose,
    required AuthUserId userId,
    required Duration duration,
  }) async {
    final token = '${purpose}_${_uuid.v4()}${_uuid.v4().replaceAll('-', '')}';
    final digest = hippobaseAuthTokenDigest(token);
    final now = DateTime.now().toUtc();
    await database.typed
        .insertInto(verifications)
        .values(
          AuthVerificationInsert(
            id: SqlValue(AuthVerificationId(_uuid.v4())),
            identifier: '$purpose:$digest',
            value: userId.value,
            expiresAt: now.add(duration),
            createdAt: now,
            updatedAt: now,
          ),
        )
        .execute();
    return token;
  }

  Future<void> storeOAuthState({required String state, required Map<String, Object?> data}) async {
    final now = DateTime.now().toUtc();
    await database.typed
        .insertInto(verifications)
        .values(
          AuthVerificationInsert(
            id: SqlValue(AuthVerificationId(_uuid.v4())),
            identifier: 'oauth-state:${hippobaseAuthTokenDigest(state)}',
            value: jsonEncode(data),
            expiresAt: now.add(const Duration(minutes: 15)),
            createdAt: now,
            updatedAt: now,
          ),
        )
        .execute();
  }

  Future<Map<String, Object?>?> consumeOAuthState(String state) {
    return database.withTransaction((transaction) async {
      final row = await transaction.typed
          .deleteFrom(verifications)
          .where(
            AuthVerificationsTable.identifier.equals(
              'oauth-state:${hippobaseAuthTokenDigest(state)}',
            ),
          )
          .executeReturningFirstOrNull();
      if (row == null || !row.expiresAt.toUtc().isAfter(DateTime.now().toUtc())) return null;
      final value = jsonDecode(row.value);
      return value is Map ? Map<String, Object?>.from(value) : null;
    });
  }

  Future<bool> resetPassword({required String token, required String passwordHash}) {
    return database.withTransaction((transaction) async {
      final identifier = 'password-reset:${hippobaseAuthTokenDigest(token)}';
      final verification = await transaction.typed
          .deleteFrom(verifications)
          .where(AuthVerificationsTable.identifier.equals(identifier))
          .executeReturningFirstOrNull();
      if (verification == null || !verification.expiresAt.toUtc().isAfter(DateTime.now().toUtc())) {
        return false;
      }
      final userId = AuthUserId(verification.value);
      final account = await credentialAccount(userId, executor: transaction);
      if (account == null) return false;
      await transaction.typed
          .updateTable(accounts)
          .set(
            AuthAccountUpdate(
              password: SqlValue(passwordHash),
              updatedAt: SqlValue(DateTime.now().toUtc()),
            ),
          )
          .where(AuthAccountsTable.id.equals(account.id))
          .execute();
      await deleteUserSessions(userId, executor: transaction);
      return true;
    });
  }

  Future<bool> verifyEmail(String token) {
    return database.withTransaction((transaction) async {
      final identifier = 'email-verification:${hippobaseAuthTokenDigest(token)}';
      final verification = await transaction.typed
          .deleteFrom(verifications)
          .where(AuthVerificationsTable.identifier.equals(identifier))
          .executeReturningFirstOrNull();
      if (verification == null || !verification.expiresAt.toUtc().isAfter(DateTime.now().toUtc())) {
        return false;
      }
      final updated = await transaction.typed
          .updateTable(users)
          .set(
            AuthUserUpdate(
              emailVerified: const SqlValue(true),
              updatedAt: SqlValue(DateTime.now().toUtc()),
            ),
          )
          .where(AuthUsersTable.id.equals(AuthUserId(verification.value)))
          .executeReturningFirstOrNull();
      return updated != null;
    });
  }
}
