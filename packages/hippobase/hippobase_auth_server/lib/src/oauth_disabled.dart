import 'package:hippobase_auth_server_engine/hippobase_auth_server_engine.dart';

final class HippobaseAuthDisabledOAuthAdapter implements HippobaseAuthOAuthAdapter {
  const HippobaseAuthDisabledOAuthAdapter();

  @override
  Future<Uri> start(
    HippobaseAuthRequestMetadata metadata, {
    required String providerId,
    required String callbackUrl,
  }) {
    throw const HippobaseAuthException(
      404,
      'OAuth2ProviderNotFound',
      'OAuth2 provider is not configured.',
    );
  }

  @override
  Future<HippobaseAuthOAuthCallbackResult> callback(
    Map<String, String> query,
    HippobaseAuthRequestMetadata metadata, {
    required String providerId,
  }) {
    throw const HippobaseAuthException(
      404,
      'OAuth2ProviderNotFound',
      'OAuth2 provider is not configured.',
    );
  }
}
