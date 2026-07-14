part of '../service.dart';

extension HippobaseAuthRecoveryService on HippobaseAuthService {
  Future<HippobaseAuthSuccessResponse> requestPasswordReset(
    HippobaseAuthRequestMetadata metadata,
    HippobaseAuthEmailRequest request,
  ) async {
    if (!options.enablePasswordManagement) return const HippobaseAuthSuccessResponse(success: true);
    await ensureRateLimit(metadata, 'password-reset:${request.email.trim().toLowerCase()}');
    ensureTrustedOrigin(metadata);
    final email = request.email.trim().toLowerCase();
    final user = await repository.userByEmail(email);
    final callback = options.notifier?.onPasswordReset;
    if (user != null && callback != null) {
      final token = await repository.createOneTimeToken(
        purpose: 'password-reset',
        userId: user.id,
        duration: options.oneTimeTokenDuration,
      );
      final expiresAt = DateTime.now().toUtc().add(options.oneTimeTokenDuration);
      final url = options.normalizedBaseUrl.resolve(
        '/views/reset-password?token=${Uri.encodeQueryComponent(token)}',
      );
      try {
        await callback(email: user.email, url: url, expiresAt: expiresAt);
      } on Object {
        // Enumeration-safe response deliberately hides notifier failures.
      }
    }
    return const HippobaseAuthSuccessResponse(success: true);
  }

  Future<HippobaseAuthSuccessResponse> resetPassword(
    HippobaseAuthRequestMetadata metadata,
    HippobaseAuthResetPasswordRequest request,
  ) async {
    if (!options.enablePasswordManagement) {
      throw const HippobaseAuthException(
        403,
        'PasswordManagementDisabled',
        'Password management is disabled.',
      );
    }
    await ensureRateLimit(metadata, 'reset-password:${hippobaseAuthTokenDigest(request.token)}');
    ensureTrustedOrigin(metadata);
    _validPassword(request.newPassword);
    final hash = await passwords.hash(request.newPassword);
    if (!await repository.resetPassword(token: request.token, passwordHash: hash)) {
      throw const HippobaseAuthException(
        400,
        'ResetPasswordInvalidToken',
        'Reset token is invalid or expired.',
      );
    }
    return const HippobaseAuthSuccessResponse(success: true);
  }

  Future<HippobaseAuthSuccessResponse> confirmEmail(
    HippobaseAuthRequestMetadata metadata,
    HippobaseAuthTokenRequest request,
  ) async {
    ensureTrustedOrigin(metadata);
    if (!await repository.verifyEmail(request.token)) {
      throw const HippobaseAuthException(
        400,
        'ConfirmMailInvalidToken',
        'Confirmation token is invalid or expired.',
      );
    }
    return const HippobaseAuthSuccessResponse(success: true);
  }
}
