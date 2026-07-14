part of '../oidc.dart';

extension HippobaseAuthOAuthProvider on HippobaseAuthOAuthService {
  HippobaseAuthSsoProvider _provider(String providerId) {
    for (final provider in options.ssoProviders) {
      if (provider.providerId == providerId) return provider;
    }
    throw const HippobaseAuthException(
      404,
      'OAuth2ProviderNotFound',
      'OAuth2 provider is not configured.',
    );
  }

  Future<Client> _client(HippobaseAuthSsoProvider provider) {
    return _clients.putIfAbsent(provider.providerId, () async {
      final issuer = await Issuer.discover(provider.issuer);
      return Client(issuer, provider.clientId, clientSecret: provider.clientSecret);
    });
  }

  Uri _providerRedirect(HippobaseAuthSsoProvider provider) {
    return provider.redirectUrl ??
        options.normalizedBaseUrl.resolve(
          '/v1/oauth2/callback/${Uri.encodeComponent(provider.providerId)}',
        );
  }

  bool _trustedCallback(Uri uri) {
    if ((uri.scheme != 'http' && uri.scheme != 'https') || uri.host.isEmpty) return false;
    if (options.allowLoopbackOAuthCallbackUrls && _isLoopback(uri.host)) return true;
    final origins = <String>{options.normalizedBaseUrl.origin};
    for (final value in options.trustedOrigins) {
      final parsed = Uri.tryParse(value);
      if (parsed != null && parsed.hasScheme && parsed.host.isNotEmpty) origins.add(parsed.origin);
    }
    return origins.contains(uri.origin);
  }

  String _randomValue(int bytes) {
    final values = List<int>.generate(bytes, (_) => _random.nextInt(256));
    return base64Url.encode(values).replaceAll('=', '');
  }
}
