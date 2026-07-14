import 'package:hippobase_auth_api_contract/hippobase_auth_api_contract.dart';
import 'package:hippobase_auth_models/hippobase_auth_models.dart';

import 'error.dart';
import 'identity.dart';
import 'oauth_identity.dart';
import 'options.dart';
import 'password.dart';
import 'rate_limit.dart';
import 'request_metadata.dart';
import 'session_tokens.dart';
import 'store.dart';

part 'services/credentials.dart';
part 'services/oauth_accounts.dart';
part 'services/recovery.dart';
part 'services/request_security.dart';
part 'services/sessions.dart';

final class HippobaseAuthService {
  const HippobaseAuthService({
    required this.options,
    required this.repository,
    required this.passwords,
    required this.rateLimiter,
  });

  final HippobaseAuthServerOptions options;
  final HippobaseAuthStore repository;
  final HippobaseAuthPasswordService passwords;
  final HippobaseAuthRateLimiter rateLimiter;
}

const _dummyPasswordHash =
    '000102030405060708090a0b0c0d0e0f:'
    '728f0dcd55b2fd21c9c1821d76b88d64121aad5cc2a18c9cd0294171901e2e82'
    'c9c42d8bb6cc00b92680423a125523fdb0d7be18eb3b92b1410a2d9e3890e198';

String _validEmail(String input) {
  final email = input.trim().toLowerCase();
  if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email)) {
    throw const HippobaseAuthException(400, 'InvalidEmail', 'Invalid email address.');
  }
  return email;
}

void _validPassword(String password) {
  if (password.length < 8) {
    throw const HippobaseAuthException(
      400,
      'PasswordTooShort',
      'Password must contain at least 8 characters.',
    );
  }
}

bool _isBanned(AuthUserRow user) {
  if (user.banned != true) return false;
  final expires = user.banExpires;
  return expires == null || expires.toUtc().isAfter(DateTime.now().toUtc());
}

String _origin(String value) {
  final uri = Uri.parse(value);
  return uri.hasScheme && uri.host.isNotEmpty ? uri.origin : value;
}

HippobaseAuthSessionPayload _sessionPayload(AuthUserRow user, AuthSessionRow session) {
  return HippobaseAuthSessionPayload(
    sessionId: session.id.value,
    token: session.token,
    expiresAt: session.expiresAt.toUtc(),
    user: user,
  );
}
