part of '../store.dart';

extension _HippobaseAuthOAuthAccountRepository on _HippobaseAuthSqlRepository {
  Future<({AuthUserRow user, AuthSessionRow session})> createOAuthUserWithSession({
    required String providerId,
    required String accountId,
    required String email,
    required String name,
    required bool emailVerified,
    required String role,
    required Duration sessionDuration,
    String? image,
    String? accessToken,
    String? refreshToken,
    String? idToken,
    String? scope,
    DateTime? accessTokenExpiresAt,
    String? ipAddress,
    String? userAgent,
  }) {
    return database.withTransaction((transaction) async {
      final now = DateTime.now().toUtc();
      final userId = AuthUserId(_uuid.v4());
      final user = await transaction.typed
          .insertInto(users)
          .values(
            AuthUserInsert(
              id: SqlValue(userId),
              name: name.trim(),
              email: email.trim().toLowerCase(),
              emailVerified: emailVerified,
              image: image,
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
      if (user == null) throw StateError('Failed to create OAuth user.');
      await transaction.typed
          .insertInto(accounts)
          .values(
            AuthAccountInsert(
              id: SqlValue(AuthAccountId(_uuid.v4())),
              accountId: accountId,
              providerId: providerId,
              userId: userId,
              accessToken: accessToken,
              refreshToken: refreshToken,
              idToken: idToken,
              accessTokenExpiresAt: accessTokenExpiresAt,
              refreshTokenExpiresAt: null,
              scope: scope,
              password: null,
              createdAt: now,
              updatedAt: now,
            ),
          )
          .execute();
      final session = await createSession(
        userId: userId,
        duration: sessionDuration,
        ipAddress: ipAddress,
        userAgent: userAgent,
        executor: transaction,
      );
      return (user: user, session: session);
    });
  }
}
