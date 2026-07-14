part of '../store.dart';

extension _HippobaseAuthUserRepository on _HippobaseAuthSqlRepository {
  Future<AuthUserRow?> userById(AuthUserId id, {SqlExecutor? executor}) {
    return (executor ?? database).typed
        .from(users)
        .selectTable(users)
        .where(AuthUsersTable.id.equals(id))
        .executeFirstOrNull();
  }

  Future<AuthUserRow?> userByEmail(String email, {SqlExecutor? executor}) {
    return (executor ?? database).typed
        .from(users)
        .selectTable(users)
        .where(AuthUsersTable.email.equals(email.trim().toLowerCase()))
        .executeFirstOrNull();
  }

  Future<AuthAccountRow?> credentialAccount(AuthUserId userId, {SqlExecutor? executor}) {
    return (executor ?? database).typed
        .from(accounts)
        .selectTable(accounts)
        .where(AuthAccountsTable.userId.equals(userId))
        .where(AuthAccountsTable.providerId.equals('credential'))
        .executeFirstOrNull();
  }

  Future<AuthAccountRow?> providerAccount(
    String providerId,
    String accountId, {
    SqlExecutor? executor,
  }) {
    return (executor ?? database).typed
        .from(accounts)
        .selectTable(accounts)
        .where(AuthAccountsTable.providerId.equals(providerId))
        .where(AuthAccountsTable.accountId.equals(accountId))
        .executeFirstOrNull();
  }

  Future<AuthUserRow> createCredentialUser({
    required String email,
    required String name,
    required String passwordHash,
    required String role,
    bool emailVerified = false,
  }) {
    return database.withTransaction((transaction) async {
      final now = DateTime.now().toUtc();
      final id = AuthUserId(_uuid.v4());
      final user = await transaction.typed
          .insertInto(users)
          .values(
            AuthUserInsert(
              id: SqlValue(id),
              name: name.trim(),
              email: email.trim().toLowerCase(),
              emailVerified: emailVerified,
              image: null,
              createdAt: now,
              updatedAt: now,
              role: role,
              banned: false,
              banReason: null,
              banExpires: null,
              phoneNumber: null,
              phoneNumberVerified: null,
            ),
          )
          .executeReturningFirstOrNull();
      if (user == null) throw StateError('Failed to create auth user.');
      await transaction.typed
          .insertInto(accounts)
          .values(
            AuthAccountInsert(
              id: SqlValue(AuthAccountId(_uuid.v4())),
              accountId: id.value,
              providerId: 'credential',
              userId: id,
              accessToken: null,
              refreshToken: null,
              idToken: null,
              accessTokenExpiresAt: null,
              refreshTokenExpiresAt: null,
              scope: null,
              password: passwordHash,
              createdAt: now,
              updatedAt: now,
            ),
          )
          .execute();
      return user;
    });
  }

  Future<({AuthUserRow user, AuthSessionRow session})> createCredentialUserWithSession({
    required String email,
    required String name,
    required String passwordHash,
    required String role,
    required bool emailVerified,
    required Duration sessionDuration,
    String? ipAddress,
    String? userAgent,
  }) {
    return database.withTransaction((transaction) async {
      final now = DateTime.now().toUtc();
      final id = AuthUserId(_uuid.v4());
      final user = await transaction.typed
          .insertInto(users)
          .values(
            AuthUserInsert(
              id: SqlValue(id),
              name: name.trim(),
              email: email.trim().toLowerCase(),
              emailVerified: emailVerified,
              image: null,
              createdAt: now,
              updatedAt: now,
              role: role,
              banned: false,
              banReason: null,
              banExpires: null,
              phoneNumber: null,
              phoneNumberVerified: null,
            ),
          )
          .executeReturningFirstOrNull();
      if (user == null) throw StateError('Failed to create auth user.');
      await transaction.typed
          .insertInto(accounts)
          .values(
            AuthAccountInsert(
              id: SqlValue(AuthAccountId(_uuid.v4())),
              accountId: id.value,
              providerId: 'credential',
              userId: id,
              accessToken: null,
              refreshToken: null,
              idToken: null,
              accessTokenExpiresAt: null,
              refreshTokenExpiresAt: null,
              scope: null,
              password: passwordHash,
              createdAt: now,
              updatedAt: now,
            ),
          )
          .execute();
      final session = await createSession(
        userId: id,
        duration: sessionDuration,
        ipAddress: ipAddress,
        userAgent: userAgent,
        executor: transaction,
      );
      return (user: user, session: session);
    });
  }
}
