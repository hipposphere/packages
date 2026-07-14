import 'dart:async';

import 'package:dart_edge_core/dart_edge_core.dart';
import 'package:hippobase_auth_api_contract/hippobase_auth_api_contract.dart';

import '../../../error.dart';
import '../../../utils/route_options.dart';
import '../../../utils/route_response.dart';
import '../../../utils/request_metadata.dart';
import '../../dependencies.dart';

final class HippobaseAuthOAuth2SignInRoute<TServices>
    extends HttpRouteDefinition<TServices, RawResponse> {
  HippobaseAuthOAuth2SignInRoute(this.dependencies);

  final HippobaseAuthRouterDependencies dependencies;

  @override
  RouteOptions get options => hippobaseAuthRouteOptions(
    HippobaseAuthRoutes.oauthSignIn.operationId,
    params: oauthSignInParamsSchema,
    query: oauthSignInQuerySchema,
    success: ResponseSpec.text(status: 302),
  );

  @override
  FutureOr<RawResponse> handle(RequestContext<TServices> context) {
    return hippobaseAuthJsonResponse(
      context,
      () async {
        final providerId = context.req.param('providerId');
        final callbackUrl = context.req.queryParam('callbackURL');
        if (providerId == null || callbackUrl == null) {
          throw const HippobaseAuthException(
            400,
            'SSOLoginInitiationFailed',
            'Missing OAuth2 provider or callback URL.',
          );
        }
        final redirect = await dependencies.oauth.start(
          hippobaseAuthRequestMetadata(context),
          providerId: providerId,
          callbackUrl: callbackUrl,
        );
        return RawResponse.text(
          status: 302,
          headers: <HttpHeader>[HttpHeader('location', redirect.toString())],
        );
      },
      code: 'SSOLoginInitiationFailed',
      message: 'Failed to initiate SSO login.',
    );
  }
}
