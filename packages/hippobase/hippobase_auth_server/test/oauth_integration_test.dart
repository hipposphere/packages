import 'dart:convert';
import 'dart:io';

import 'package:dart_edge_http_server/dart_edge_http_server.dart' hide SqlPool;
import 'package:dart_edge_sql/dart_edge_sql.dart';
import 'package:hippobase_auth_server/hippobase_auth_server.dart';
import 'package:hippobase_auth_server_oidc/hippobase_auth_server_oidc.dart';
import 'package:hippobase_auth_server_sql/hippobase_auth_server_sql.dart';
import 'package:test/test.dart';

import 'support/fake_oidc_provider.dart';

void main() {
  test('OIDC flow validates state, PKCE, nonce, collisions, and account reuse', () async {
    final provider = await FakeOidcProvider.start();
    final database = SqliteDatabase.inMemory();
    await _createSchema(database);
    final auth = HippobaseAuthServer(
      HippobaseAuthServerOptions(
        secret: 'test-secret-key-that-is-at-least-32-characters-long',
        baseUrl: 'http://127.0.0.1:3000',
        passwordWorkerCount: 1,
        ssoProviders: <HippobaseAuthSsoProvider>[
          HippobaseAuthSsoProvider(
            providerId: 'fake',
            issuer: provider.issuer,
            clientId: 'callo-test',
            clientSecret: 'client-secret',
          ),
        ],
      ),
      store: HippobaseAuthSqlStore(database),
      oauthAdapterFactory: const HippobaseAuthOidcAdapterFactory(),
    );
    final app = DartEdge<void>(services: () {});
    auth.mountPublic(app);
    final server = await app.listen(port: 0, workers: 1);
    final client = HttpClient();
    final baseUri = Uri.http('127.0.0.1:${server.port}');
    addTearDown(() async {
      client.close(force: true);
      await server.close();
      await auth.close();
      await database.close();
      await provider.close();
    });

    final invalidOrigin = await _post(
      client,
      baseUri.resolve('/v1/user/sign-in-sso'),
      <String, Object?>{
        'provider_id': 'fake',
        'success_url': 'https://untrusted.example.test/complete',
      },
    );
    expect(invalidOrigin.status, 400);

    final providerError = await _get(
      client,
      baseUri.resolve('/v1/oauth2/callback/fake?error=access_denied'),
    );
    expect(providerError.status, 400);
    expect(_errorCode(providerError), 'OAuth2CallbackFailed');

    final unknownState = await _get(
      client,
      baseUri.resolve('/v1/oauth2/callback/fake?code=valid&state=unknown'),
    );
    expect(unknownState.status, 400);
    expect(_errorCode(unknownState), 'OAuth2CallbackUnknownState');

    final invalidNonceStart = await _startFlow(client, baseUri);
    provider.prepare(invalidNonceStart.authorizationUri, invalidNonce: true);
    final invalidNonce = await _callback(client, baseUri, state: invalidNonceStart.state);
    expect(invalidNonce.status, 401, reason: invalidNonce.body);
    expect(_errorCode(invalidNonce), 'OAuth2TokenInvalid');

    final firstStart = await _startFlow(client, baseUri);
    provider.prepare(firstStart.authorizationUri);
    final first = await _callback(client, baseUri, state: firstStart.state);
    expect(first.status, 302, reason: first.body);
    expect(provider.pkceVerified, isTrue);
    final firstLocation = Uri.parse(first.headers.value(HttpHeaders.locationHeader)!);
    final firstToken = firstLocation.queryParameters['token'];
    expect(firstToken, startsWith('session_'));
    final currentUser = await _get(
      client,
      baseUri.resolve('/v1/user/get_user'),
      headers: <String, String>{'authorization': 'Bearer $firstToken'},
    );
    expect(currentUser.status, 200, reason: currentUser.body);
    expect(((currentUser.json['user']! as Map<String, Object?>)['email']), 'oauth@example.com');

    final replay = await _callback(client, baseUri, state: firstStart.state);
    expect(replay.status, 400);
    expect(_errorCode(replay), 'OAuth2CallbackUnknownState');

    final reusedStart = await _startFlow(client, baseUri);
    provider.prepare(reusedStart.authorizationUri);
    final reused = await _callback(client, baseUri, state: reusedStart.state);
    expect(reused.status, 302, reason: reused.body);
    expect(await auth.repository.countUsers(), 1);

    await auth.trustedAdmin.createUser(
      email: 'collision@example.com',
      password: 'password123',
      name: 'Existing User',
    );
    provider
      ..subject = 'oauth-collision'
      ..email = 'collision@example.com';
    final collisionStart = await _startFlow(client, baseUri);
    provider.prepare(collisionStart.authorizationUri);
    final collision = await _callback(client, baseUri, state: collisionStart.state);
    expect(collision.status, 409, reason: collision.body);
    expect(_errorCode(collision), 'OAuth2EmailCollision');
    expect(await auth.repository.countUsers(), 2);
  });
}

Future<_StartedFlow> _startFlow(HttpClient client, Uri baseUri) async {
  final response = await _post(client, baseUri.resolve('/v1/user/sign-in-sso'), <String, Object?>{
    'provider_id': 'fake',
    'success_url': 'http://127.0.0.1:9876/complete',
  });
  expect(response.status, 200, reason: response.body);
  final data = response.json['data']! as Map<String, Object?>;
  final authorizationUri = Uri.parse(data['redirectUrl']! as String);
  return _StartedFlow(authorizationUri, authorizationUri.queryParameters['state']!);
}

Future<_Response> _callback(HttpClient client, Uri baseUri, {required String state}) {
  return _get(
    client,
    baseUri.resolve('/v1/oauth2/callback/fake?code=valid&state=${Uri.encodeQueryComponent(state)}'),
  );
}

String? _errorCode(_Response response) {
  return (response.json['error'] as Map<String, Object?>?)?['code'] as String?;
}

final class _StartedFlow {
  const _StartedFlow(this.authorizationUri, this.state);

  final Uri authorizationUri;
  final String state;
}

Future<void> _createSchema(SqlPool database) async {
  for (final statement in <String>[
    '''CREATE TABLE "user" ("id" TEXT PRIMARY KEY, "name" TEXT NOT NULL, "email" TEXT NOT NULL UNIQUE, "emailVerified" BOOLEAN NOT NULL, "image" TEXT, "createdAt" TIMESTAMP NOT NULL, "updatedAt" TIMESTAMP NOT NULL, "role" TEXT, "banned" BOOLEAN, "banReason" TEXT, "banExpires" TIMESTAMP, "phoneNumber" TEXT, "phoneNumberVerified" BOOLEAN)''',
    '''CREATE TABLE "session" ("id" TEXT PRIMARY KEY, "expiresAt" TIMESTAMP NOT NULL, "token" TEXT NOT NULL UNIQUE, "createdAt" TIMESTAMP NOT NULL, "updatedAt" TIMESTAMP NOT NULL, "ipAddress" TEXT, "userAgent" TEXT, "userId" TEXT NOT NULL REFERENCES "user"("id") ON DELETE CASCADE, "impersonatedBy" TEXT)''',
    '''CREATE TABLE "account" ("id" TEXT PRIMARY KEY, "accountId" TEXT NOT NULL, "providerId" TEXT NOT NULL, "userId" TEXT NOT NULL REFERENCES "user"("id") ON DELETE CASCADE, "accessToken" TEXT, "refreshToken" TEXT, "idToken" TEXT, "accessTokenExpiresAt" TIMESTAMP, "refreshTokenExpiresAt" TIMESTAMP, "scope" TEXT, "password" TEXT, "createdAt" TIMESTAMP NOT NULL, "updatedAt" TIMESTAMP NOT NULL, UNIQUE("providerId", "accountId"))''',
    '''CREATE TABLE "verification" ("id" TEXT PRIMARY KEY, "identifier" TEXT NOT NULL, "value" TEXT NOT NULL, "expiresAt" TIMESTAMP NOT NULL, "createdAt" TIMESTAMP NOT NULL, "updatedAt" TIMESTAMP NOT NULL)''',
  ]) {
    await database.execute(sql(statement));
  }
}

Future<_Response> _post(HttpClient client, Uri uri, Map<String, Object?> body) async {
  final request = await client.postUrl(uri);
  request.headers.contentType = ContentType.json;
  request.write(jsonEncode(body));
  return _read(await request.close());
}

Future<_Response> _get(
  HttpClient client,
  Uri uri, {
  Map<String, String> headers = const <String, String>{},
}) async {
  final request = await client.getUrl(uri);
  request.followRedirects = false;
  headers.forEach(request.headers.set);
  return _read(await request.close());
}

Future<_Response> _read(HttpClientResponse response) async {
  final body = await utf8.decoder.bind(response).join();
  final decoded = body.isEmpty ? <String, Object?>{} : jsonDecode(body) as Map<String, Object?>;
  return _Response(response.statusCode, response.headers, body, decoded);
}

final class _Response {
  const _Response(this.status, this.headers, this.body, this.json);

  final int status;
  final HttpHeaders headers;
  final String body;
  final Map<String, Object?> json;
}
