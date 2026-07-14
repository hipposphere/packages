import 'dart:async';

import 'package:dart_edge_core/dart_edge_core.dart';
import 'package:hippobase_auth_api_contract/hippobase_auth_api_contract.dart';

import '../../../error.dart';
import '../../../utils/route_options.dart';
import '../../../utils/route_response.dart';
import '../../../utils/request_metadata.dart';
import '../../dependencies.dart';

final class HippobaseAuthOAuth2CallbackRoute<TServices>
    extends HttpRouteDefinition<TServices, RawResponse> {
  HippobaseAuthOAuth2CallbackRoute(this.dependencies);

  final HippobaseAuthRouterDependencies dependencies;

  @override
  RouteOptions get options => hippobaseAuthRouteOptions(
    HippobaseAuthRoutes.oauthCallback.operationId,
    params: oauthSignInParamsSchema,
    query: oauthCallbackQuerySchema,
    success: ResponseSpec.text(status: 302),
  );

  @override
  FutureOr<RawResponse> handle(RequestContext<TServices> context) {
    return hippobaseAuthJsonResponse(
      context,
      () async {
        final providerId = context.req.param('providerId');
        if (providerId == null) {
          throw const HippobaseAuthException(
            400,
            'OAuth2CallbackFailed',
            'Missing OAuth2 provider.',
          );
        }
        final result = await dependencies.oauth.callback(
          context.req.queryMap,
          hippobaseAuthRequestMetadata(context),
          providerId: providerId,
        );
        return RawResponse.text(
          status: 302,
          headers: <HttpHeader>[
            HttpHeader('location', result.redirect.toString()),
            HttpHeader('set-cookie', dependencies.tokens.setCookie(result.token, result.expiresAt)),
            HttpHeader('set-auth-token', result.token),
          ],
        );
      },
      code: 'OAuth2CallbackFailed',
      message: 'OAuth2 callback failed.',
    );
  }
}
