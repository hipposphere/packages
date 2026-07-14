part of '../store.dart';

extension _HippobaseAuthSessionRepository on _HippobaseAuthSqlRepository {
  Future<AuthSessionRow> createSession({
    required AuthUserId userId,
    required Duration duration,
    String? ipAddress,
    String? userAgent,
    SqlExecutor? executor,
  }) async {
    final now = DateTime.now().toUtc();
    final session = await (executor ?? database).typed
        .insertInto(sessions)
        .values(
          AuthSessionInsert(
            id: SqlValue(AuthSessionId(_uuid.v4())),
            expiresAt: now.add(duration),
            token: 'session_${_uuid.v4()}',
            createdAt: now,
            updatedAt: now,
            ipAddress: ipAddress,
            userAgent: userAgent,
            userId: userId,
            impersonatedBy: null,
          ),
        )
        .executeReturningFirstOrNull();
    if (session == null) throw StateError('Failed to create auth session.');
    return session;
  }

  Future<AuthSessionRow?> sessionByToken(String token, {SqlExecutor? executor}) {
    return (executor ?? database).typed
        .from(sessions)
        .selectTable(sessions)
        .where(AuthSessionsTable.token.equals(token))
        .executeFirstOrNull();
  }

  Future<void> updateSessionExpiry(AuthSessionId id, DateTime expiresAt) async {
    await database.typed
        .updateTable(sessions)
        .set(
          AuthSessionUpdate(
            expiresAt: SqlValue(expiresAt),
            updatedAt: SqlValue(DateTime.now().toUtc()),
          ),
        )
        .where(AuthSessionsTable.id.equals(id))
        .execute();
  }

  Future<bool> deleteSessionByToken(String token) async {
    final deleted = await database.typed
        .deleteFrom(sessions)
        .where(AuthSessionsTable.token.equals(token))
        .executeReturningFirstOrNull();
    return deleted != null;
  }

  Future<void> deleteUserSessions(AuthUserId userId, {SqlExecutor? executor}) async {
    await (executor ?? database).typed
        .deleteFrom(sessions)
        .where(AuthSessionsTable.userId.equals(userId))
        .execute();
  }
}
