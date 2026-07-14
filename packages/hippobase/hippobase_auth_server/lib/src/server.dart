import 'package:dart_edge_core/dart_edge_core.dart';
import 'package:hippobase_auth_server_engine/hippobase_auth_server_engine.dart';

import 'oauth_disabled.dart';
import 'router/dependencies.dart';
import 'router/router.dart';

final class HippobaseAuthServer {
  HippobaseAuthServer(
    this.options, {
    required HippobaseAuthStore store,
    HippobaseAuthOAuthAdapterFactory? oauthAdapterFactory,
    HippobaseAuthPasswordService? passwordService,
    HippobaseAuthRateLimiter? rateLimiter,
  }) : passwords =
           passwordService ??
           HippobaseAuthScryptPasswordService(workerCount: options.passwordWorkerCount),
       repository = store,
       tokens = HippobaseAuthSessionTokenCodec(
         secret: options.secret,
         baseUrl: options.normalizedBaseUrl,
         cookieName: options.sessionCookieName,
       ),
       rateLimiter = rateLimiter ?? options.rateLimiter ?? HippobaseAuthMemoryRateLimiter() {
    if (options.ssoProviders.isNotEmpty && oauthAdapterFactory == null) {
      throw ArgumentError.value(
        oauthAdapterFactory,
        'oauthAdapterFactory',
        'An OAuth adapter factory is required when SSO providers are configured.',
      );
    }
    service = HippobaseAuthService(
      options: options,
      repository: repository,
      passwords: passwords,
      rateLimiter: this.rateLimiter,
    );
    oauth =
        oauthAdapterFactory?.create(options: options, store: repository, service: service) ??
        const HippobaseAuthDisabledOAuthAdapter();
    trustedAdmin = HippobaseAuthTrustedAdmin(
      repository: repository,
      passwords: passwords,
      options: options.admin,
    );
    _routerDependencies = HippobaseAuthRouterDependencies(
      options: options,
      repository: repository,
      service: service,
      oauth: oauth,
      tokens: tokens,
      trustedAdmin: trustedAdmin,
    );
  }

  final HippobaseAuthServerOptions options;
  final HippobaseAuthPasswordService passwords;
  final HippobaseAuthStore repository;
  final HippobaseAuthSessionTokenCodec tokens;
  final HippobaseAuthRateLimiter rateLimiter;
  late final HippobaseAuthService service;
  late final HippobaseAuthOAuthAdapter oauth;
  late final HippobaseAuthTrustedAdmin trustedAdmin;
  late final HippobaseAuthRouterDependencies _routerDependencies;

  Router<TServices> createPublicRouter<TServices>({String basePath = ''}) {
    final router = Router<TServices>();
    mountPublic(router, basePath: basePath);
    return router;
  }

  Router<TServices> createAdminRouter<TServices>({String basePath = '', Guard<TServices>? guard}) {
    final router = Router<TServices>();
    mountAdmin(router, basePath: basePath, guard: guard);
    return router;
  }

  void mountPublic<TServices>(Router<TServices> router, {String basePath = ''}) {
    mountHippobaseAuthPublicRouter(router, dependencies: _routerDependencies, basePath: basePath);
  }

  void mountAdmin<TServices>(
    Router<TServices> router, {
    String basePath = '',
    Guard<TServices>? guard,
  }) {
    mountHippobaseAuthAdminRouter(
      router,
      dependencies: _routerDependencies,
      basePath: basePath,
      guard: guard,
    );
  }

  Future<void> close() => passwords.close();
}
