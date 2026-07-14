import 'package:hippobase_auth_models/hippobase_auth_models.dart';

abstract interface class HippobaseAuthStore {
  Future<AuthUserRow?> userById(AuthUserId id);

  Future<AuthUserRow?> userByEmail(String email);

  Future<AuthAccountRow?> credentialAccount(AuthUserId userId);

  Future<AuthAccountRow?> providerAccount(String providerId, String accountId);

  Future<AuthUserRow> createCredentialUser({
    required String email,
    required String name,
    required String passwordHash,
    required String role,
    bool emailVerified = false,
  });

  Future<({AuthUserRow user, AuthSessionRow session})> createCredentialUserWithSession({
    required String email,
    required String name,
    required String passwordHash,
    required String role,
    required bool emailVerified,
    required Duration sessionDuration,
    String? ipAddress,
    String? userAgent,
  });

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
  });

  Future<AuthSessionRow> createSession({
    required AuthUserId userId,
    required Duration duration,
    String? ipAddress,
    String? userAgent,
  });

  Future<AuthSessionRow?> sessionByToken(String token);

  Future<void> updateSessionExpiry(AuthSessionId id, DateTime expiresAt);

  Future<bool> deleteSessionByToken(String token);

  Future<String> createOneTimeToken({
    required String purpose,
    required AuthUserId userId,
    required Duration duration,
  });

  Future<void> storeOAuthState({required String state, required Map<String, Object?> data});

  Future<Map<String, Object?>?> consumeOAuthState(String state);

  Future<bool> resetPassword({required String token, required String passwordHash});

  Future<bool> verifyEmail(String token);

  Future<List<AuthUserRow>> listUsers({required int limit, required int offset});

  Future<int> countUsers();

  Future<AuthUserRow?> updateRole(AuthUserId userId, String role);

  Future<bool> deleteUser(AuthUserId userId);
}
