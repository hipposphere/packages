import 'dart:async';

import 'package:dart_edge_core/dart_edge_core.dart';
import 'package:hippobase_auth_api_contract/hippobase_auth_api_contract.dart';

import '../../../utils/route_options.dart';
import '../../../utils/route_response.dart';
import '../../../utils/request_metadata.dart';
import '../../dependencies.dart';

final class HippobaseAuthSignInSsoRoute<TServices>
    extends HttpRouteDefinition<TServices, RawResponse> {
  HippobaseAuthSignInSsoRoute(this.dependencies);

  final HippobaseAuthRouterDependencies dependencies;

  @override
  RouteOptions get options => hippobaseAuthRouteOptions(
    HippobaseAuthRoutes.signInSso.operationId,
    body: HippobaseAuthSignInSsoRequest.requestBody,
    success: HippobaseAuthSignInSsoResponse.response,
  );

  @override
  FutureOr<RawResponse> handle(RequestContext<TServices> context) {
    return hippobaseAuthJsonResponse(
      context,
      () async {
        final request = context.req.body<HippobaseAuthSignInSsoRequest>();
        final redirect = await dependencies.oauth.start(
          hippobaseAuthRequestMetadata(context),
          providerId: request.providerId,
          callbackUrl: request.successUrl,
        );
        return HippobaseAuthSignInSsoResponse(
          success: true,
          data: <String, Object?>{
            'providerId': request.providerId,
            'redirectUrl': redirect.toString(),
          },
        );
      },
      code: 'SSOLoginInitiationFailed',
      message: 'Failed to initiate SSO login.',
    );
  }
}
