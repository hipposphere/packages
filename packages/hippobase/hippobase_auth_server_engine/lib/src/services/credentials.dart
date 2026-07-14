part of '../service.dart';

extension HippobaseAuthCredentialService on HippobaseAuthService {
  HippobaseAuthInfoResponse info() {
    return HippobaseAuthInfoResponse(
      emailSignInEnabled: options.emailSignInEnabled,
      emailSignUpEnabled: options.emailSignUpEnabled,
      ssoProviders: options.ssoProviders
          .map((provider) => provider.toJson())
          .toList(growable: false),
    );
  }

  Future<HippobaseAuthSessionPayload> signUp(
    HippobaseAuthRequestMetadata metadata,
    HippobaseAuthSignUpEmailRequest request,
  ) async {
    if (!options.emailSignUpEnabled) {
      throw const HippobaseAuthException(403, 'SignUpEmailDisabled', 'Email sign up is disabled.');
    }
    await ensureRateLimit(metadata, 'sign-up:${request.email.trim().toLowerCase()}');
    ensureTrustedOrigin(metadata);
    final email = _validEmail(request.email);
    _validPassword(request.password);
    final name = request.name.trim();
    if (name.isEmpty) {
      throw const HippobaseAuthException(400, 'SignUpEmailInvalidName', 'Name must not be empty.');
    }
    if (await repository.userByEmail(email) != null) {
      throw const HippobaseAuthException(
        409,
        'UserAlreadyExists',
        'A user with this email already exists.',
      );
    }
    final hash = await passwords.hash(request.password);
    late ({AuthUserRow user, AuthSessionRow session}) created;
    try {
      created = await repository.createCredentialUserWithSession(
        email: email,
        name: name,
        passwordHash: hash,
        role: options.admin.defaultUserRole,
        emailVerified: !options.enableEmailVerification,
        sessionDuration: options.sessionDuration,
        ipAddress: metadata.ipAddress,
        userAgent: metadata.userAgent,
      );
    } on Object {
      if (await repository.userByEmail(email) != null) {
        throw const HippobaseAuthException(
          409,
          'UserAlreadyExists',
          'A user with this email already exists.',
        );
      }
      rethrow;
    }
    if (options.enableEmailVerification && options.notifier?.onEmailVerification != null) {
      final token = await repository.createOneTimeToken(
        purpose: 'email-verification',
        userId: created.user.id,
        duration: options.oneTimeTokenDuration,
      );
      final expiresAt = DateTime.now().toUtc().add(options.oneTimeTokenDuration);
      final url = options.normalizedBaseUrl.resolve(
        '/views/confirm-mail?token=${Uri.encodeQueryComponent(token)}',
      );
      try {
        await options.notifier!.onEmailVerification!(email: email, url: url, expiresAt: expiresAt);
      } on Object {
        // Account creation remains successful when an external notifier is unavailable.
      }
    }
    return _sessionPayload(created.user, created.session);
  }

  Future<HippobaseAuthSessionPayload> signIn(
    HippobaseAuthRequestMetadata metadata,
    HippobaseAuthSignInEmailRequest request,
  ) async {
    if (!options.emailSignInEnabled) {
      throw const HippobaseAuthException(403, 'SignInEmailDisabled', 'Email sign in is disabled.');
    }
    await ensureRateLimit(metadata, 'sign-in:${request.email.trim().toLowerCase()}');
    ensureTrustedOrigin(metadata);
    final email = _validEmail(request.email);
    final user = await repository.userByEmail(email);
    final account = user == null ? null : await repository.credentialAccount(user.id);
    final valid = await passwords.verify(request.password, account?.password ?? _dummyPasswordHash);
    if (!valid || user == null || account == null || _isBanned(user)) {
      throw const HippobaseAuthException(401, 'InvalidCredentials', 'Invalid email or password.');
    }
    final session = await repository.createSession(
      userId: user.id,
      duration: options.sessionDuration,
      ipAddress: metadata.ipAddress,
      userAgent: metadata.userAgent,
    );
    return _sessionPayload(user, session);
  }
}
