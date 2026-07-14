import 'package:hippobase_auth_server_engine/hippobase_auth_server_engine.dart';

export 'package:hippobase_auth_server_engine/hippobase_auth_server_engine.dart'
    show
        HippobaseAuthCredentialService,
        HippobaseAuthOAuthAccountService,
        HippobaseAuthRecoveryService,
        HippobaseAuthRequestSecurityService,
        HippobaseAuthSessionService;

final class HippobaseAuthRouterDependencies {
  const HippobaseAuthRouterDependencies({
    required this.options,
    required this.repository,
    required this.service,
    required this.oauth,
    required this.tokens,
    required this.trustedAdmin,
  });

  final HippobaseAuthServerOptions options;
  final HippobaseAuthStore repository;
  final HippobaseAuthService service;
  final HippobaseAuthOAuthAdapter oauth;
  final HippobaseAuthSessionTokenCodec tokens;
  final HippobaseAuthTrustedAdmin trustedAdmin;
}
