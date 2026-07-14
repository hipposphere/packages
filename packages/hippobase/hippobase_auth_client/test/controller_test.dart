import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:hippobase_auth_client/hippobase_auth_client.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  test('restores a persisted session', () async {
    final storage = HippobaseAuthMemorySessionStorage()
      ..value = HippobaseAuthSession(
        id: 'session-1',
        token: 'token-1',
        expiresAt: DateTime.now().toUtc().add(const Duration(days: 10)),
      );
    final controller = _controller(storage, (_) async => http.Response('{}', 200));
    addTearDown(controller.dispose);

    await controller.ready;

    expect(controller.state.value, isA<HippobaseAuthenticated>());
    expect(controller.currentSession?.token, 'token-1');
  });

  test('signs in, persists the session, and signs out remotely', () async {
    final storage = HippobaseAuthMemorySessionStorage();
    final methods = <String>[];
    final controller = _controller(storage, (request) async {
      methods.add('${request.method} ${request.url.path}');
      if (request.url.path.endsWith('/sign-in-email')) {
        return http.Response(jsonEncode(_sessionPayload()), 200);
      }
      if (request.url.path.endsWith('/logout')) {
        expect(request.headers['authorization'], 'Bearer token-1');
        return http.Response(jsonEncode(<String, Object?>{'user': _user()}), 200);
      }
      return http.Response('{}', 404);
    });
    addTearDown(controller.dispose);
    await controller.ready;

    await controller.signInWithEmail(email: 'ada@example.com', password: 'password123');

    expect(storage.value?.token, 'token-1');
    expect(controller.state.value, isA<HippobaseAuthenticated>());

    await controller.signOut();

    expect(storage.value, isNull);
    expect(controller.state.value, isA<HippobaseUnauthenticated>());
    expect(
      methods,
      containsAll(<String>['POST /auth/v1/user/sign-in-email', 'GET /auth/v1/user/logout']),
    );
  });

  test('refresh failure clears the persisted session', () async {
    final storage = HippobaseAuthMemorySessionStorage()
      ..value = HippobaseAuthSession(
        id: 'session-1',
        token: 'token-1',
        expiresAt: DateTime.now().toUtc().add(const Duration(hours: 1)),
      );
    final controller = _controller(
      storage,
      (_) async => http.Response(
        jsonEncode(<String, Object?>{
          'error': <String, Object?>{'code': 'Unauthorized', 'message': 'Unauthorized.'},
        }),
        401,
      ),
    );
    addTearDown(controller.dispose);
    await controller.ready;

    expect(await controller.authorizationToken(), isNull);
    expect(storage.value, isNull);
    expect(controller.state.value, isA<HippobaseUnauthenticated>());
  });

  test('keeps the unauthenticated state for a failed sign-in', () async {
    final controller = _controller(
      HippobaseAuthMemorySessionStorage(),
      (_) async => http.Response(
        jsonEncode(<String, Object?>{
          'error': <String, Object?>{
            'code': 'InvalidCredentials',
            'message': 'Invalid email or password.',
          },
        }),
        401,
      ),
    );
    addTearDown(controller.dispose);
    await controller.ready;

    await expectLater(
      controller.signInWithEmail(email: 'ada@example.com', password: 'wrong-password'),
      throwsA(isA<HippobaseAuthApiException>()),
    );
    expect(controller.state.value, isA<HippobaseUnauthenticated>());
  });
}

HippobaseAuthController _controller(
  HippobaseAuthSessionStorage storage,
  Future<http.Response> Function(http.Request request) handler,
) {
  return HippobaseAuthController.create(
    baseUrl: Uri.parse('https://api.example.test/auth'),
    storage: storage,
    httpClient: MockClient(handler),
  );
}

Map<String, Object?> _sessionPayload() => <String, Object?>{
  'session_id': 'session-1',
  'token': 'token-1',
  'expires_at': DateTime.now().toUtc().add(const Duration(days: 90)).toIso8601String(),
  'user': _user(),
};

Map<String, Object?> _user() => <String, Object?>{
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
};
