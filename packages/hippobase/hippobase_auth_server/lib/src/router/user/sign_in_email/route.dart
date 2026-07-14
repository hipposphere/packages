import 'dart:async';

import 'package:dart_edge_core/dart_edge_core.dart';
import 'package:hippobase_auth_api_contract/hippobase_auth_api_contract.dart';

import '../../../utils/route_options.dart';
import '../../../utils/route_response.dart';
import '../../../utils/request_metadata.dart';
import '../../../utils/session_response.dart';
import '../../dependencies.dart';

final class HippobaseAuthSignInEmailRoute<TServices>
    extends HttpRouteDefinition<TServices, RawResponse> {
  HippobaseAuthSignInEmailRoute(this.dependencies);

  final HippobaseAuthRouterDependencies dependencies;

  @override
  RouteOptions get options => hippobaseAuthRouteOptions(
    HippobaseAuthRoutes.signInEmail.operationId,
    body: HippobaseAuthSignInEmailRequest.requestBody,
    success: HippobaseAuthSessionPayload.response,
  );

  @override
  FutureOr<RawResponse> handle(RequestContext<TServices> context) {
    return hippobaseAuthJsonResponse(
      context,
      () async {
        final session = await dependencies.service.signIn(
          hippobaseAuthRequestMetadata(context),
          context.req.body<HippobaseAuthSignInEmailRequest>(),
        );
        applyHippobaseAuthSession(context, dependencies.tokens, session);
        return session;
      },
      code: 'SignInEmailFailed',
      message: 'Sign in failed.',
      defaultStatus: 401,
    );
  }
}
