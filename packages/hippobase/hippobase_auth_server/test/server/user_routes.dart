import 'dart:io';

import 'package:test/test.dart';

import '../support/auth_test_harness.dart';

void registerUserRouteTests() {
  group('schema-less SQLite user routes', () {
    late AuthTestHarness harness;

    setUp(() async => harness = await AuthTestHarness.start());
    tearDown(() => harness.close());

    test('signup, sign-in, bearer guard, and real logout', () async {
      final signup = await postJson(
        harness.client,
        harness.baseUri.resolve('/v1/user/sign-up-email'),
        <String, Object?>{
          'name': 'Ada Lovelace',
          'email': 'ada@example.com',
          'password': 'password123',
        },
      );
      expect(signup.status, 200, reason: signup.body);
      final token = signup.json['token']! as String;
      expect(token, startsWith('session_'));
      expect(signup.headers.value(HttpHeaders.setCookieHeader), contains('.'));

      final invalid = await postJson(
        harness.client,
        harness.baseUri.resolve('/v1/user/sign-in-email'),
        <String, Object?>{'email': 'ada@example.com', 'password': 'wrong-password'},
      );
      expect(invalid.status, 401);
      expect((invalid.json['error']! as Map<String, Object?>)['code'], 'InvalidCredentials');

      final getUser = await getJson(
        harness.client,
        harness.baseUri.resolve('/v1/user/get_user'),
        headers: <String, String>{'authorization': 'Bearer $token'},
      );
      expect(getUser.status, 200, reason: getUser.body);
      expect((getUser.json['user']! as Map<String, Object?>)['email'], 'ada@example.com');

      final logout = await getJson(
        harness.client,
        harness.baseUri.resolve('/v1/user/logout'),
        headers: <String, String>{'authorization': 'Bearer $token'},
      );
      expect(logout.status, 200, reason: logout.body);
      expect(logout.headers.value(HttpHeaders.setCookieHeader), contains('Max-Age=0'));
      final revoked = await getJson(
        harness.client,
        harness.baseUri.resolve('/v1/user/get_user'),
        headers: <String, String>{'authorization': 'Bearer $token'},
      );
      expect(revoked.status, 401);
    });

    test('refreshes near-expiry and rejects expired sessions', () async {
      final signup = await postJson(
        harness.client,
        harness.baseUri.resolve('/v1/user/sign-up-email'),
        <String, Object?>{
          'name': 'Refresh User',
          'email': 'refresh@example.com',
          'password': 'password123',
        },
      );
      final token = signup.json['token']! as String;
      final session = await harness.auth.repository.sessionByToken(token);
      await harness.auth.repository.updateSessionExpiry(
        session!.id,
        DateTime.now().toUtc().add(const Duration(hours: 1)),
      );
      final refreshed = await postJson(
        harness.client,
        harness.baseUri.resolve('/v1/user/refresh-session'),
        const <String, Object?>{},
        headers: <String, String>{
          'authorization': 'Bearer $token',
          'origin': 'https://untrusted.example.test',
        },
      );
      expect(refreshed.status, 200, reason: refreshed.body);
      expect(
        DateTime.parse(refreshed.json['expires_at']! as String).difference(DateTime.now().toUtc()),
        greaterThan(const Duration(days: 89)),
      );

      await harness.auth.repository.updateSessionExpiry(
        session.id,
        DateTime.now().toUtc().subtract(const Duration(seconds: 1)),
      );
      final expired = await getJson(
        harness.client,
        harness.baseUri.resolve('/v1/user/get_user'),
        headers: <String, String>{'authorization': 'Bearer $token'},
      );
      expect(expired.status, 401);
    });

    test('validates origins for cookie-authenticated mutations', () async {
      final signup = await postJson(
        harness.client,
        harness.baseUri.resolve('/v1/user/sign-up-email'),
        <String, Object?>{
          'name': 'Cookie User',
          'email': 'cookie@example.com',
          'password': 'password123',
        },
      );
      final cookie = signup.headers.value(HttpHeaders.setCookieHeader)!.split(';').first;
      final rejected = await getJson(
        harness.client,
        harness.baseUri.resolve('/v1/user/logout'),
        headers: <String, String>{'cookie': cookie, 'origin': 'https://untrusted.example.test'},
      );
      expect(rejected.status, 403);
      expect((rejected.json['error']! as Map<String, Object?>)['code'], 'UntrustedOrigin');
    });
  });
}
