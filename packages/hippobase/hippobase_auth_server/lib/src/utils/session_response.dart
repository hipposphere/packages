import 'package:dart_edge_core/dart_edge_core.dart';
import 'package:hippobase_auth_api_contract/hippobase_auth_api_contract.dart';
import 'package:hippobase_auth_server_engine/hippobase_auth_server_engine.dart';

void applyHippobaseAuthSession<TServices>(
  RequestContext<TServices> context,
  HippobaseAuthSessionTokenCodec tokens,
  HippobaseAuthSessionPayload session,
) {
  context.res.header('set-cookie', tokens.setCookie(session.token, session.expiresAt));
  context.res.header('set-auth-token', session.token);
}
