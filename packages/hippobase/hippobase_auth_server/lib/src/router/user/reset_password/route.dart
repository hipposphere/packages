import 'dart:async';

import 'package:dart_edge_core/dart_edge_core.dart';
import 'package:hippobase_auth_api_contract/hippobase_auth_api_contract.dart';

import '../../../utils/route_options.dart';
import '../../../utils/route_response.dart';
import '../../../utils/request_metadata.dart';
import '../../dependencies.dart';

final class HippobaseAuthResetPasswordRoute<TServices>
    extends HttpRouteDefinition<TServices, RawResponse> {
  HippobaseAuthResetPasswordRoute(this.dependencies);

  final HippobaseAuthRouterDependencies dependencies;

  @override
  RouteOptions get options => hippobaseAuthRouteOptions(
    HippobaseAuthRoutes.resetPassword.operationId,
    body: HippobaseAuthResetPasswordRequest.requestBody,
    success: HippobaseAuthSuccessResponse.response,
  );

  @override
  FutureOr<RawResponse> handle(RequestContext<TServices> context) {
    return hippobaseAuthJsonResponse(
      context,
      () => dependencies.service.resetPassword(
        hippobaseAuthRequestMetadata(context),
        context.req.body<HippobaseAuthResetPasswordRequest>(),
      ),
      code: 'ResetPasswordFailed',
      message: 'Reset password failed.',
    );
  }
}
