import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:jose/jose.dart';

final class FakeOidcProvider {
  FakeOidcProvider._(this.server, this.key) : issuer = Uri.http('127.0.0.1:${server.port}');

  static Future<FakeOidcProvider> start() async {
    final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
    final generated = JsonWebKey.generate('RS256', keyBitLength: 2048);
    final key = JsonWebKey.fromJson(<String, dynamic>{
      ...generated.toJson(),
      'kid': 'fake-signing-key',
      'alg': 'RS256',
      'use': 'sig',
    });
    final provider = FakeOidcProvider._(server, key);
    server.listen(provider._handle);
    return provider;
  }

  final HttpServer server;
  final JsonWebKey key;
  final Uri issuer;
  String subject = 'oauth-user';
  String email = 'oauth@example.com';
  String? _nonce;
  String? _challenge;
  bool _invalidNonce = false;
  bool pkceVerified = false;

  void prepare(Uri authorizationUri, {bool invalidNonce = false}) {
    _nonce = authorizationUri.queryParameters['nonce'];
    _challenge = authorizationUri.queryParameters['code_challenge'];
    _invalidNonce = invalidNonce;
    pkceVerified = false;
  }

  Future<void> _handle(HttpRequest request) async {
    try {
      switch (request.uri.path) {
        case '/.well-known/openid-configuration':
          await _json(request.response, <String, Object?>{
            'issuer': issuer.toString(),
            'authorization_endpoint': issuer.resolve('/authorize').toString(),
            'token_endpoint': issuer.resolve('/token').toString(),
            'jwks_uri': issuer.resolve('/jwks').toString(),
            'scopes_supported': <String>['openid', 'email', 'profile'],
            'response_types_supported': <String>['code'],
            'subject_types_supported': <String>['public'],
            'id_token_signing_alg_values_supported': <String>['RS256'],
            'token_endpoint_auth_methods_supported': <String>['client_secret_post'],
            'code_challenge_methods_supported': <String>['S256'],
          });
        case '/jwks':
          final publicKey = JsonWebKey.fromCryptoKeys(
            publicKey: key.cryptoKeyPair.publicKey,
            keyId: 'fake-signing-key',
          ).toJson();
          await _json(request.response, <String, Object?>{
            'keys': <Object?>[
              <String, Object?>{...publicKey, 'alg': 'RS256', 'use': 'sig'},
            ],
          });
        case '/token':
          final body = await utf8.decoder.bind(request).join();
          final form = Uri.splitQueryString(body);
          final verifier = form['code_verifier'] ?? '';
          final calculated = base64Url
              .encode(sha256.convert(utf8.encode(verifier)).bytes)
              .replaceAll('=', '');
          pkceVerified = form['code'] == 'valid' && calculated == _challenge;
          if (!pkceVerified) {
            request.response.statusCode = 400;
            await _json(request.response, <String, Object?>{'error': 'invalid_grant'});
            return;
          }
          await _json(request.response, <String, Object?>{
            'access_token': 'fake-access-token',
            'token_type': 'Bearer',
            'expires_in': 3600,
            'scope': 'openid email profile',
            'id_token': _idToken(),
          });
        default:
          request.response.statusCode = 404;
          await request.response.close();
      }
    } on Object catch (error, stackTrace) {
      request.response.statusCode = 500;
      await _json(request.response, <String, Object?>{
        'error': error.toString(),
        'stack': stackTrace.toString(),
      });
    }
  }

  String _idToken() {
    final now = DateTime.now().toUtc().millisecondsSinceEpoch ~/ 1000;
    final builder = JsonWebSignatureBuilder()
      ..jsonContent = <String, Object?>{
        'iss': issuer.toString(),
        'sub': subject,
        'aud': 'callo-test',
        'iat': now,
        'exp': now + 3600,
        'nonce': _invalidNonce ? 'invalid-nonce' : _nonce,
        'email': email,
        'email_verified': true,
        'name': 'OAuth Test User',
      }
      ..setProtectedHeader('typ', 'JWT')
      ..setProtectedHeader('kid', 'fake-signing-key')
      ..addRecipient(key, algorithm: 'RS256');
    return builder.build().toCompactSerialization();
  }

  Future<void> close() => server.close(force: true);
}

Future<void> _json(HttpResponse response, Map<String, Object?> body) async {
  response.headers.contentType = ContentType.json;
  response.write(jsonEncode(body));
  await response.close();
}
