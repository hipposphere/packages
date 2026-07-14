import 'package:hippobase_auth_models/hippobase_auth_models.dart';

final class HippobaseAuthIdentity {
  const HippobaseAuthIdentity({
    required this.session,
    required this.user,
    required this.token,
    required this.fromCookie,
  });

  final AuthSessionRow session;
  final AuthUserRow user;
  final String token;
  final bool fromCookie;
}
