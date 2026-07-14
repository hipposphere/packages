import 'dart:async';

import 'package:dart_edge_core/dart_edge_core.dart';
import 'package:hippobase_auth_api_contract/hippobase_auth_api_contract.dart';

import '../../../utils/route_options.dart';
import '../../../utils/route_response.dart';
import '../../../utils/request_metadata.dart';
import '../../dependencies.dart';

final class HippobaseAuthConfirmMailRoute<TServices>
    extends HttpRouteDefinition<TServices, RawResponse> {
  HippobaseAuthConfirmMailRoute(this.dependencies);

  final HippobaseAuthRouterDependencies dependencies;

  @override
  RouteOptions get options => hippobaseAuthRouteOptions(
    HippobaseAuthRoutes.confirmMail.operationId,
    body: HippobaseAuthTokenRequest.requestBody,
    success: HippobaseAuthSuccessResponse.response,
  );

  @override
  FutureOr<RawResponse> handle(RequestContext<TServices> context) {
    return hippobaseAuthJsonResponse(
      context,
      () => dependencies.service.confirmEmail(
        hippobaseAuthRequestMetadata(context),
        context.req.body<HippobaseAuthTokenRequest>(),
      ),
      code: 'ConfirmMailFailed',
      message: 'Confirm mail failed.',
    );
  }
}
