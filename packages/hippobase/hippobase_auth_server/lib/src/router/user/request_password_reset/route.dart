import 'dart:async';

import 'package:dart_edge_core/dart_edge_core.dart';
import 'package:hippobase_auth_api_contract/hippobase_auth_api_contract.dart';

import '../../../utils/route_options.dart';
import '../../../utils/route_response.dart';
import '../../../utils/request_metadata.dart';
import '../../dependencies.dart';

final class HippobaseAuthRequestPasswordResetRoute<TServices>
    extends HttpRouteDefinition<TServices, RawResponse> {
  HippobaseAuthRequestPasswordResetRoute(this.dependencies);

  final HippobaseAuthRouterDependencies dependencies;

  @override
  RouteOptions get options => hippobaseAuthRouteOptions(
    HippobaseAuthRoutes.requestPasswordReset.operationId,
    body: HippobaseAuthEmailRequest.requestBody,
    success: HippobaseAuthSuccessResponse.response,
  );

  @override
  FutureOr<RawResponse> handle(RequestContext<TServices> context) {
    return hippobaseAuthJsonResponse(
      context,
      () => dependencies.service.requestPasswordReset(
        hippobaseAuthRequestMetadata(context),
        context.req.body<HippobaseAuthEmailRequest>(),
      ),
      code: 'RequestPasswordResetFailed',
      message: 'Request password reset failed.',
    );
  }
}
