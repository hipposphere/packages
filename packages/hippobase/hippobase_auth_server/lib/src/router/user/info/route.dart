import 'dart:async';

import 'package:dart_edge_core/dart_edge_core.dart';
import 'package:hippobase_auth_api_contract/hippobase_auth_api_contract.dart';

import '../../../utils/route_options.dart';
import '../../../utils/route_response.dart';
import '../../dependencies.dart';

final class HippobaseAuthInfoRoute<TServices> extends HttpRouteDefinition<TServices, RawResponse> {
  HippobaseAuthInfoRoute(this.dependencies);

  final HippobaseAuthRouterDependencies dependencies;

  @override
  RouteOptions get options => hippobaseAuthRouteOptions(
    HippobaseAuthRoutes.info.operationId,
    success: HippobaseAuthInfoResponse.response,
  );

  @override
  FutureOr<RawResponse> handle(RequestContext<TServices> context) {
    return hippobaseAuthJsonResponse(
      context,
      dependencies.service.info,
      code: 'GetUserInfoFailed',
      message: 'Failed to load authentication info.',
    );
  }
}
