part of '../oidc.dart';

extension HippobaseAuthOAuthStart on HippobaseAuthOAuthService {
  Future<Uri> start(
    HippobaseAuthRequestMetadata metadata, {
    required String providerId,
    required String callbackUrl,
  }) async {
    await auth.ensureRateLimit(metadata, 'oauth-start:$providerId');
    auth.ensureTrustedOrigin(metadata);
    final provider = _provider(providerId);
    final callback = Uri.tryParse(callbackUrl);
    if (callback == null || !_trustedCallback(callback)) {
      throw const HippobaseAuthException(
        400,
        'SSOLoginInitiationFailed',
        'callbackURL must be an absolute http(s) URL on the auth origin, a trusted origin, or a loopback origin.',
      );
    }
    final state = _randomValue(24);
    final nonce = _randomValue(24);
    final verifier = _randomValue(48);
    final redirectUri = _providerRedirect(provider);
    final client = await _client(provider);
    final flow = Flow.authorizationCodeWithPKCE(
      client,
      state: state,
      codeVerifier: verifier,
      scopes: provider.scopes,
      additionalParameters: <String, String>{'nonce': nonce},
    )..redirectUri = redirectUri;
    await repository.storeOAuthState(
      state: state,
      data: <String, Object?>{
        'provider_id': provider.providerId,
        'callback_url': callback.toString(),
        'redirect_uri': redirectUri.toString(),
        'verifier': verifier,
        'nonce': nonce,
      },
    );
    return flow.authenticationUri;
  }
}
