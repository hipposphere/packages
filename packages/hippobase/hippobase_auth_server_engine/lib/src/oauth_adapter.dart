import 'options.dart';
import 'request_metadata.dart';
import 'service.dart';
import 'store.dart';

abstract interface class HippobaseAuthOAuthAdapter {
  Future<Uri> start(
    HippobaseAuthRequestMetadata metadata, {
    required String providerId,
    required String callbackUrl,
  });

  Future<HippobaseAuthOAuthCallbackResult> callback(
    Map<String, String> query,
    HippobaseAuthRequestMetadata metadata, {
    required String providerId,
  });
}

abstract interface class HippobaseAuthOAuthAdapterFactory {
  HippobaseAuthOAuthAdapter create({
    required HippobaseAuthServerOptions options,
    required HippobaseAuthStore store,
    required HippobaseAuthService service,
  });
}

final class HippobaseAuthOAuthCallbackResult {
  const HippobaseAuthOAuthCallbackResult({
    required this.redirect,
    required this.token,
    required this.sessionId,
    required this.expiresAt,
  });

  final Uri redirect;
  final String token;
  final String sessionId;
  final DateTime expiresAt;
}
