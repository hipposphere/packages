import 'dart:async';

import 'package:dart_edge_core/dart_edge_core.dart';
import 'package:hippobase_auth_api_contract/hippobase_auth_api_contract.dart';

import '../../../guard.dart';
import '../../../utils/request_metadata.dart';
import '../../../utils/route_options.dart';
import '../../../utils/route_response.dart';
import '../../dependencies.dart';

final class HippobaseAuthRefreshSessionRoute<TServices>
    extends HttpRouteDefinition<TServices, RawResponse> {
  HippobaseAuthRefreshSessionRoute(this.dependencies);

  final HippobaseAuthRouterDependencies dependencies;

  @override
  RouteOptions get options => hippobaseAuthRouteOptions(
    HippobaseAuthRoutes.refreshSession.operationId,
    success: HippobaseAuthRefreshSessionResponse.response,
  );

  @override
  FutureOr<RawResponse> handle(RequestContext<TServices> context) {
    return hippobaseAuthJsonResponse(
      context,
      () async {
        final identity = context.requireHippobaseAuthIdentity;
        final response = await dependencies.service.refresh(
          hippobaseAuthRequestMetadata(context),
          identity,
        );
        context.res.header(
          'set-cookie',
          dependencies.tokens.setCookie(identity.token, response.expiresAt),
        );
        return response;
      },
      code: 'RefreshSessionFailed',
      message: 'Refresh session failed.',
      defaultStatus: 401,
    );
  }
}
