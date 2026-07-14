import 'dart:async';

import 'package:dart_edge_core/dart_edge_core.dart';
import 'package:hippobase_auth_api_contract/hippobase_auth_api_contract.dart';

import '../../../guard.dart';
import '../../../utils/request_metadata.dart';
import '../../../utils/route_options.dart';
import '../../../utils/route_response.dart';
import '../../dependencies.dart';

final class HippobaseAuthLogoutRoute<TServices>
    extends HttpRouteDefinition<TServices, RawResponse> {
  HippobaseAuthLogoutRoute(this.dependencies);

  final HippobaseAuthRouterDependencies dependencies;

  @override
  RouteOptions get options => hippobaseAuthRouteOptions(
    HippobaseAuthRoutes.logout.operationId,
    success: HippobaseAuthLogoutResponse.response,
  );

  @override
  FutureOr<RawResponse> handle(RequestContext<TServices> context) {
    return hippobaseAuthJsonResponse(
      context,
      () async {
        final response = await dependencies.service.logout(
          hippobaseAuthRequestMetadata(context),
          context.requireHippobaseAuthIdentity,
        );
        context.res.header('set-cookie', dependencies.tokens.expiredCookie());
        return response;
      },
      code: 'LogoutFailed',
      message: 'Logout failed.',
    );
  }
}
