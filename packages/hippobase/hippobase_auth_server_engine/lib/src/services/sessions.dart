part of '../service.dart';

extension HippobaseAuthSessionService on HippobaseAuthService {
  Future<HippobaseAuthLogoutResponse> logout(
    HippobaseAuthRequestMetadata metadata,
    HippobaseAuthIdentity identity,
  ) async {
    ensureTrustedOrigin(metadata, identity: identity);
    await repository.deleteSessionByToken(identity.token);
    return HippobaseAuthLogoutResponse(user: identity.user);
  }

  Future<HippobaseAuthRefreshSessionResponse> refresh(
    HippobaseAuthRequestMetadata metadata,
    HippobaseAuthIdentity identity,
  ) async {
    ensureTrustedOrigin(metadata, identity: identity);
    final now = DateTime.now().toUtc();
    if (!identity.session.expiresAt.toUtc().isAfter(now)) {
      throw const HippobaseAuthException(401, 'RefreshSessionInvalidRequest', 'Session expired.');
    }
    if (identity.session.expiresAt.toUtc().isAfter(now.add(options.refreshThreshold))) {
      throw const HippobaseAuthException(
        401,
        'RefreshSessionInvalidRequest',
        'Session is still valid.',
      );
    }
    final expiresAt = now.add(options.sessionDuration);
    await repository.updateSessionExpiry(identity.session.id, expiresAt);
    return HippobaseAuthRefreshSessionResponse(expiresAt: expiresAt);
  }
}
