import 'dart:async';

import 'package:dart_edge_core/dart_edge_core.dart';
import 'package:hippobase_auth_api_contract/hippobase_auth_api_contract.dart';

import '../../../guard.dart';
import '../../../utils/route_options.dart';
import '../../../utils/route_response.dart';
import '../../dependencies.dart';

final class HippobaseAuthGetUserRoute<TServices>
    extends HttpRouteDefinition<TServices, RawResponse> {
  HippobaseAuthGetUserRoute(this.dependencies);

  final HippobaseAuthRouterDependencies dependencies;

  @override
  RouteOptions get options => hippobaseAuthRouteOptions(
    HippobaseAuthRoutes.getUser.operationId,
    success: HippobaseAuthUserResponse.response,
  );

  @override
  FutureOr<RawResponse> handle(RequestContext<TServices> context) {
    return hippobaseAuthJsonResponse(
      context,
      () => HippobaseAuthUserResponse(user: context.requireHippobaseAuthIdentity.user),
      code: 'GetUserFailed',
      message: 'Failed to load user.',
    );
  }
}
