import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_web_auth_2/flutter_web_auth_2.dart';
import 'package:hippo_core/hippo_core.dart';
import 'package:hippo_core_flutter/hippo_core_flutter.dart';
import 'package:http/http.dart' as http;

import '../api/admin_client.dart';
import '../api/client.dart';
import '../models/session.dart';
import '../models/state.dart';
import '../storage/session_storage.dart';

final class HippobaseAuthController extends BlocBase {
  HippobaseAuthController._({
    required this.client,
    required this.adminClient,
    required this.storage,
  }) {
    unawaited(_restore());
  }

  factory HippobaseAuthController.create({
    required Uri baseUrl,
    required HippobaseAuthSessionStorage storage,
    http.Client? httpClient,
  }) {
    late HippobaseAuthController controller;
    final client = HippobaseAuthClient(
      baseUrl: baseUrl,
      tokenProvider: () => controller.currentSession?.token,
      httpClient: httpClient,
    );
    final adminClient = HippobaseAuthAdminClient(
      baseUrl: baseUrl,
      tokenProvider: () => controller.currentSession?.token,
      httpClient: httpClient,
    );
    controller = HippobaseAuthController._(
      client: client,
      adminClient: adminClient,
      storage: storage,
    );
    return controller;
  }

  final HippobaseAuthClient client;
  final HippobaseAuthAdminClient adminClient;
  final HippobaseAuthSessionStorage storage;
  final DataSubject<HippobaseAuthState> state = DataSubject.seeded(const HippobaseAuthLoading());
  final Completer<void> _ready = Completer<void>();

  Future<void> get ready => _ready.future;

  HippobaseAuthSession? get currentSession => state.value.session;

  Future<void> _restore() async {
    try {
      final session = await storage.read();
      state.add(
        session == null ? const HippobaseUnauthenticated() : HippobaseAuthenticated(session),
      );
    } catch (error) {
      state.add(HippobaseAuthFailure(error));
    } finally {
      if (!_ready.isCompleted) _ready.complete();
    }
  }

  Future<void> signUpWithEmail({
    required String name,
    required String email,
    required String password,
  }) async {
    final payload = await client.signUpWithEmail(name: name, email: email, password: password);
    await setSession(
      HippobaseAuthSession(
        id: payload.sessionId,
        token: payload.token,
        expiresAt: payload.expiresAt,
      ),
    );
  }

  Future<void> signInWithEmail({required String email, required String password}) async {
    final payload = await client.signInWithEmail(email: email, password: password);
    await setSession(
      HippobaseAuthSession(
        id: payload.sessionId,
        token: payload.token,
        expiresAt: payload.expiresAt,
      ),
    );
  }

  Future<void> oauth2SignIn({
    required String provider,
    required Uri callbackUrl,
    required String callbackUrlScheme,
    FlutterWebAuth2Options options = const FlutterWebAuth2Options(useWebview: false),
  }) async {
    state.add(const HippobaseAuthLoading());
    try {
      final result = await FlutterWebAuth2.authenticate(
        url: client.oauth2SignInUrl(provider: provider, callbackUrl: callbackUrl).toString(),
        callbackUrlScheme: callbackUrlScheme,
        options: options,
      );
      final query = Uri.parse(result).queryParameters;
      await setSession(
        HippobaseAuthSession(
          id: query['session_id']!,
          token: query['token']!,
          expiresAt: DateTime.parse(query['expires_at']!),
        ),
      );
    } catch (error) {
      state.add(HippobaseAuthFailure(error));
      rethrow;
    }
  }

  Future<void> setSession(HippobaseAuthSession session) async {
    await storage.write(session);
    state.add(HippobaseAuthenticated(session));
  }

  Future<void> clearSession() async {
    await storage.clear();
    state.add(const HippobaseUnauthenticated());
  }

  Future<void> signOut() async {
    try {
      if (currentSession != null) await client.logout();
    } on Object {
      // Local credentials must still be removed when the server is unavailable.
    } finally {
      await clearSession();
    }
  }

  Future<HippobaseAuthSession?> refreshSession() async {
    final session = currentSession;
    if (session == null || session.isExpired) {
      await clearSession();
      return null;
    }
    try {
      final response = await client.refreshSession();
      final refreshed = session.copyWith(expiresAt: response.expiresAt);
      await setSession(refreshed);
      return refreshed;
    } on Object {
      await clearSession();
      return null;
    }
  }

  Future<String?> authorizationToken() async {
    var session = currentSession;
    if (session == null) return null;
    if (session.isExpired) {
      await clearSession();
      return null;
    }
    if (session.canBeRefreshed) session = await refreshSession();
    return session?.token;
  }

  @override
  void dispose() {
    client.close();
    adminClient.close();
    state.close();
  }

  static HippobaseAuthController of(BuildContext context) {
    return BlocProvider.of<HippobaseAuthController>(context);
  }
}
