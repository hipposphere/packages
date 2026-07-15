import 'dart:convert';

import 'package:hippobase_auth_client/hippobase_auth_client.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:test/test.dart';

void main() {
  test('public client maps auth routes to typed contract responses', () async {
    String? token;
    final requests = <http.Request>[];
    final client = HippobaseAuthClient(
      baseUrl: Uri.parse('https://api.example.test/auth'),
      tokenProvider: () => token,
      httpClient: MockClient((request) async {
        requests.add(request);
        if (request.url.path.endsWith('/sign-in-email')) {
          return http.Response(jsonEncode(_sessionPayload()), 200);
        }
        if (request.url.path.endsWith('/refresh-session')) {
          return http.Response(
            jsonEncode(<String, Object?>{
              'expires_at': DateTime.utc(2026, 12, 1).toIso8601String(),
            }),
            200,
          );
        }
        return http.Response('{}', 404);
      }),
    );
    addTearDown(client.close);

    final session = await client.signInWithEmail(email: 'ada@example.com', password: 'password123');
    token = session.token;
    final refreshed = await client.refreshSession();

    expect(session.sessionId, 'session-1');
    expect(refreshed.expiresAt, DateTime.utc(2026, 12, 1));
    expect(requests.map((request) => request.url.path), <String>[
      '/auth/v1/user/sign-in-email',
      '/auth/v1/user/refresh-session',
    ]);
    expect(requests.first.headers, isNot(contains('authorization')));
    expect(requests.last.headers['authorization'], 'Bearer token-1');
  });

  test('public client does not require a token provider for public routes', () async {
    final client = HippobaseAuthClient(
      baseUrl: Uri.parse('https://api.example.test/auth'),
      httpClient: MockClient((request) async {
        expect(request.headers, isNot(contains('authorization')));
        return http.Response(
          jsonEncode(<String, Object?>{
            'email_sign_in_enabled': true,
            'email_sign_up_enabled': false,
            'sso_providers': <Object?>[],
          }),
          200,
        );
      }),
    );
    addTearDown(client.close);

    final info = await client.info();

    expect(info.emailSignInEnabled, isTrue);
    expect(info.emailSignUpEnabled, isFalse);
  });
}

Map<String, Object?> _sessionPayload() => <String, Object?>{
  'session_id': 'session-1',
  'token': 'token-1',
  'expires_at': DateTime.utc(2026, 12, 1).toIso8601String(),
  'user': <String, Object?>{
    'id': 'user-1',
    'name': 'Ada Lovelace',
    'email': 'ada@example.com',
    'emailVerified': true,
    'image': null,
    'createdAt': '2026-07-13T10:00:00.000Z',
    'updatedAt': '2026-07-13T10:00:00.000Z',
    'role': 'user',
    'banned': false,
    'banReason': null,
    'banExpires': null,
    'phoneNumber': null,
    'phoneNumberVerified': null,
  },
};
