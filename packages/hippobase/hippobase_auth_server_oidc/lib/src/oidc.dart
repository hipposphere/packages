import 'dart:convert';
import 'dart:math';

import 'package:hippobase_auth_server_engine/hippobase_auth_server_engine.dart';
import 'package:openid_client/openid_client.dart';

part 'oidc/callback.dart';
part 'oidc/provider.dart';
part 'oidc/start.dart';

final class HippobaseAuthOAuthService {
  HippobaseAuthOAuthService({required this.options, required this.repository, required this.auth});

  final HippobaseAuthServerOptions options;
  final HippobaseAuthStore repository;
  final HippobaseAuthService auth;
  final Map<String, Future<Client>> _clients = <String, Future<Client>>{};
  final Random _random = Random.secure();
}

final class HippobaseAuthOidcAdapter implements HippobaseAuthOAuthAdapter {
  HippobaseAuthOidcAdapter({
    required HippobaseAuthServerOptions options,
    required HippobaseAuthStore store,
    required HippobaseAuthService service,
  }) : _service = HippobaseAuthOAuthService(options: options, repository: store, auth: service);

  final HippobaseAuthOAuthService _service;

  @override
  Future<Uri> start(
    HippobaseAuthRequestMetadata metadata, {
    required String providerId,
    required String callbackUrl,
  }) {
    return _service.start(metadata, providerId: providerId, callbackUrl: callbackUrl);
  }

  @override
  Future<HippobaseAuthOAuthCallbackResult> callback(
    Map<String, String> query,
    HippobaseAuthRequestMetadata metadata, {
    required String providerId,
  }) {
    return _service.callback(query, metadata, providerId: providerId);
  }
}

bool _isLoopback(String host) {
  final normalized = host.toLowerCase();
  if (normalized == 'localhost' || normalized == '::1' || normalized == '[::1]') return true;
  final parts = normalized.split('.');
  return parts.length == 4 &&
      parts.first == '127' &&
      parts.every((part) {
        final value = int.tryParse(part);
        return value != null && value >= 0 && value <= 255;
      });
}

final class HippobaseAuthOidcAdapterFactory implements HippobaseAuthOAuthAdapterFactory {
  const HippobaseAuthOidcAdapterFactory();

  @override
  HippobaseAuthOAuthAdapter create({
    required HippobaseAuthServerOptions options,
    required HippobaseAuthStore store,
    required HippobaseAuthService service,
  }) {
    return HippobaseAuthOidcAdapter(options: options, store: store, service: service);
  }
}
