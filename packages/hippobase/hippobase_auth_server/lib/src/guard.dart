import 'package:dart_edge_core/dart_edge_core.dart';
import 'package:hippobase_auth_server_engine/hippobase_auth_server_engine.dart';

import 'error.dart';

extension HippobaseAuthRequestContext<TServices> on RequestContext<TServices> {
  HippobaseAuthIdentity get requireHippobaseAuthIdentity => require<HippobaseAuthIdentity>();
}

final class HippobaseAuthGuard<TServices> implements Guard<TServices> {
  const HippobaseAuthGuard({required this.repository, required this.tokens, this.allowedRoles});

  final HippobaseAuthStore repository;
  final HippobaseAuthSessionTokenCodec tokens;
  final List<String>? allowedRoles;

  @override
  Future<GuardResult> authorize(RequestContext<TServices> ctx) async {
    final resolved = tokens.resolve(ctx.req.headersMap);
    if (resolved == null) return _deny(401, 'Unauthorized', 'Unauthorized.');
    final session = await repository.sessionByToken(resolved.token);
    final now = DateTime.now().toUtc();
    if (session == null || !session.expiresAt.toUtc().isAfter(now)) {
      return _deny(401, 'Unauthorized', 'Unauthorized.');
    }
    final user = await repository.userById(session.userId);
    final banned =
        user?.banned == true && (user!.banExpires == null || user.banExpires!.toUtc().isAfter(now));
    if (user == null || banned) {
      return _deny(401, 'Unauthorized', 'Unauthorized.');
    }
    final identity = HippobaseAuthIdentity(
      session: session,
      user: user,
      token: resolved.token,
      fromCookie: resolved.fromCookie,
    );
    ctx.put(identity);
    if (!_hasAllowedRole(user.role, allowedRoles)) {
      return _deny(403, 'Forbidden', 'Forbidden.');
    }
    return const GuardResult.allow();
  }

  GuardResult _deny(int status, String code, String message) {
    return GuardResult.deny(hippobaseAuthErrorResponse(status, code, message));
  }

  @override
  String toString() => 'HippobaseAuthGuard<$TServices>()';
}

bool _hasAllowedRole(String? rawRole, List<String>? allowedRoles) {
  if (allowedRoles == null) return true;
  final allowed = allowedRoles.map((role) => role.trim()).where((role) => role.isNotEmpty).toSet();
  if (allowed.isEmpty) return true;
  return (rawRole ?? '').split(',').map((role) => role.trim()).any(allowed.contains);
}
