import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hippobase_auth_flutter/hippobase_auth_flutter.dart';
import 'package:http/testing.dart';

void main() {
  testWidgets('gate transitions from loading to unauthenticated', (tester) async {
    final storage = _DelayedStorage();
    final controller = HippobaseAuthController.create(
      baseUrl: Uri.parse('https://api.example.test/auth'),
      storage: storage,
      httpClient: MockClient((_) async => throw StateError('unexpected request')),
    );
    addTearDown(controller.dispose);

    await tester.pumpWidget(
      MaterialApp(
        home: HippobaseAuthGate<String, String>(
          controller: controller,
          createAuthenticated: (_) => 'authenticated',
          createUnauthenticated: () => 'unauthenticated',
          authenticatedBuilder: (_, data, _) => Text(data),
          unauthenticatedBuilder: (_, data) => Text(data),
          loadingBuilder: (_) => const Text('loading'),
          errorBuilder: (_, failure) => Text('error:${failure.error}'),
        ),
      ),
    );

    expect(find.text('loading'), findsOneWidget);

    storage.complete();
    await tester.pumpAndSettle();

    expect(find.text('unauthenticated'), findsOneWidget);
  });

  testWidgets('login form exposes email, password, and submit controls', (tester) async {
    final controller = HippobaseAuthController.create(
      baseUrl: Uri.parse('https://api.example.test/auth'),
      storage: HippobaseAuthMemorySessionStorage(),
      httpClient: MockClient((_) async => throw StateError('offline')),
    );
    addTearDown(controller.dispose);
    await controller.ready;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(body: HippobaseAuthLoginForm(controller: controller)),
      ),
    );

    expect(find.byType(TextField), findsNWidgets(2));
    expect(find.text('Sign in'), findsOneWidget);
    expect(find.byTooltip('Show password'), findsOneWidget);
  });
}

final class _DelayedStorage implements HippobaseAuthSessionStorage {
  final Completer<void> _read = Completer<void>();

  void complete() => _read.complete();

  @override
  Future<void> clear() async {}

  @override
  Future<HippobaseAuthSession?> read() async {
    await _read.future;
    return null;
  }

  @override
  Future<void> write(HippobaseAuthSession session) async {}
}
