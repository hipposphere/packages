import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hippobase_auth_flutter/hippobase_auth_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  testWidgets('provides the focused auth controller to descendants', (tester) async {
    final controller = _controller((_) async => http.Response('{}', 404));
    addTearDown(controller.dispose);
    await controller.ready;

    await tester.pumpWidget(
      HippobaseAuthProvider(
        controller: controller,
        child: Builder(
          builder: (context) {
            return Text(
              identical(HippobaseAuthProvider.of(context), controller) ? 'provided' : 'missing',
              textDirection: TextDirection.ltr,
            );
          },
        ),
      ),
    );

    expect(find.text('provided'), findsOneWidget);
  });

  testWidgets('renders client state after signing in through the server binding', (tester) async {
    late http.Request request;
    final controller = _controller((incoming) async {
      request = incoming;
      return http.Response(jsonEncode(_sessionPayload()), 200);
    });
    addTearDown(controller.dispose);
    await controller.ready;

    await tester.pumpWidget(
      MaterialApp(
        home: HippobaseAuthProvider(
          controller: controller,
          child: HippobaseAuthView(
            loadingBuilder: (_) => const Text('loading'),
            unauthenticatedBuilder: (_) => const Text('signed out'),
            authenticatedBuilder: (_, session) => Text('session:${session.id}'),
            failureBuilder: (_, error) => Text('error:$error'),
          ),
        ),
      ),
    );

    expect(find.text('signed out'), findsOneWidget);

    await controller.signInWithEmail(email: 'ada@example.com', password: 'password123');
    await tester.pump();

    expect(request.method, 'POST');
    expect(request.url.path, '/auth/v1/user/sign-in-email');
    expect(find.text('session:session-1'), findsOneWidget);
  });
}

HippobaseAuthController _controller(Future<http.Response> Function(http.Request request) handler) {
  return HippobaseAuthController.create(
    baseUrl: Uri.parse('https://api.example.test/auth'),
    storage: HippobaseAuthMemorySessionStorage(),
    httpClient: MockClient(handler),
  );
}

Map<String, Object?> _sessionPayload() => <String, Object?>{
  'session_id': 'session-1',
  'token': 'token-1',
  'expires_at': DateTime.now().toUtc().add(const Duration(days: 90)).toIso8601String(),
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
