part of '../oidc.dart';

extension HippobaseAuthOAuthCallback on HippobaseAuthOAuthService {
  Future<HippobaseAuthOAuthCallbackResult> callback(
    Map<String, String> query,
    HippobaseAuthRequestMetadata metadata, {
    required String providerId,
  }) async {
    if (query['error']?.isNotEmpty == true) {
      throw const HippobaseAuthException(
        400,
        'OAuth2CallbackFailed',
        'OAuth provider rejected the request.',
      );
    }
    final code = query['code'];
    final state = query['state'];
    if (code == null || code.isEmpty || state == null || state.isEmpty) {
      throw const HippobaseAuthException(
        400,
        'OAuth2CallbackFailed',
        'Missing OAuth2 callback code or state.',
      );
    }
    final saved = await repository.consumeOAuthState(state);
    if (saved == null || saved['provider_id'] != providerId) {
      throw const HippobaseAuthException(
        400,
        'OAuth2CallbackUnknownState',
        'OAuth2 callback state is unknown or expired.',
      );
    }
    final callbackUrl = Uri.parse(saved['callback_url']! as String);
    if (!_trustedCallback(callbackUrl)) {
      throw const HippobaseAuthException(
        400,
        'OAuth2CallbackInvalidOrigin',
        'OAuth2 callback origin is not trusted.',
      );
    }
    final provider = _provider(providerId);
    final client = await _client(provider);
    final flow = Flow.authorizationCodeWithPKCE(
      client,
      state: state,
      codeVerifier: saved['verifier']! as String,
      scopes: provider.scopes,
      additionalParameters: <String, String>{'nonce': saved['nonce']! as String},
    )..redirectUri = Uri.parse(saved['redirect_uri']! as String);

    final Credential credential;
    try {
      credential = await flow.callback(<String, String>{'code': code, 'state': state});
      final violations = await credential.validateToken().toList();
      if (violations.isNotEmpty || credential.idToken.claims.nonce != saved['nonce']) {
        throw const HippobaseAuthException(
          401,
          'OAuth2TokenInvalid',
          'OAuth2 identity token validation failed.',
        );
      }
    } on HippobaseAuthException {
      rethrow;
    } on Object {
      throw const HippobaseAuthException(
        401,
        'OAuth2CallbackExchangeFailed',
        'OAuth2 callback exchange failed.',
      );
    }

    final claims = credential.idToken.claims;
    UserInfo? info;
    try {
      info = await credential.getUserInfo();
    } on Object {
      info = null;
    }
    final subject = info?.subject ?? claims.subject;
    final email = (info?.email ?? claims.email)?.trim().toLowerCase();
    final verified = info?.emailVerified ?? claims.emailVerified ?? false;
    if (subject.isEmpty || email == null || email.isEmpty || !verified) {
      throw const HippobaseAuthException(
        401,
        'OAuth2ClaimsInvalid',
        'OAuth2 provider did not return a verified email identity.',
      );
    }
    final response = credential.response ?? const <String, dynamic>{};
    final session = await auth.completeOAuthSignIn(
      metadata,
      HippobaseAuthVerifiedOAuthIdentity(
        providerId: providerId,
        accountId: subject,
        email: email,
        name: info?.name ?? claims.name ?? email,
        image: (info?.picture ?? claims.picture)?.toString(),
        accessToken: response['access_token']?.toString(),
        refreshToken: response['refresh_token']?.toString(),
        idToken: response['id_token']?.toString(),
        scope: response['scope']?.toString(),
      ),
    );
    final redirect = callbackUrl.replace(
      queryParameters: <String, String>{
        ...callbackUrl.queryParameters,
        'token': session.token,
        'session_id': session.sessionId,
        'expires_at': session.expiresAt.toUtc().toIso8601String(),
      },
    );
    return HippobaseAuthOAuthCallbackResult(
      redirect: redirect,
      token: session.token,
      sessionId: session.sessionId,
      expiresAt: session.expiresAt,
    );
  }
}
