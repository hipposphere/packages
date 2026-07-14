part of '../service.dart';

extension HippobaseAuthOAuthAccountService on HippobaseAuthService {
  Future<HippobaseAuthSessionPayload> completeOAuthSignIn(
    HippobaseAuthRequestMetadata metadata,
    HippobaseAuthVerifiedOAuthIdentity identity,
  ) async {
    final providerAccount = await repository.providerAccount(
      identity.providerId,
      identity.accountId,
    );
    if (providerAccount != null) {
      final user = await repository.userById(providerAccount.userId);
      if (user == null) {
        throw const HippobaseAuthException(
          401,
          'OAuth2AccountInvalid',
          'OAuth2 account is not linked to a user.',
        );
      }
      final session = await repository.createSession(
        userId: user.id,
        duration: options.sessionDuration,
        ipAddress: metadata.ipAddress,
        userAgent: metadata.userAgent,
      );
      return _sessionPayload(user, session);
    }
    if (await repository.userByEmail(identity.email) != null) {
      throw const HippobaseAuthException(
        409,
        'OAuth2EmailCollision',
        'An account with this email already exists and was not linked automatically.',
      );
    }
    final created = await repository.createOAuthUserWithSession(
      providerId: identity.providerId,
      accountId: identity.accountId,
      email: identity.email,
      name: identity.name,
      emailVerified: true,
      role: options.admin.defaultUserRole,
      sessionDuration: options.sessionDuration,
      image: identity.image,
      accessToken: identity.accessToken,
      refreshToken: identity.refreshToken,
      idToken: identity.idToken,
      scope: identity.scope,
      accessTokenExpiresAt: identity.accessTokenExpiresAt,
      ipAddress: metadata.ipAddress,
      userAgent: metadata.userAgent,
    );
    return _sessionPayload(created.user, created.session);
  }
}
