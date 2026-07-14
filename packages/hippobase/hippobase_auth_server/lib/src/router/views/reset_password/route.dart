import 'dart:async';

import 'package:dart_edge_core/dart_edge_core.dart';

import '../../dependencies.dart';
import '../html.dart';

final class HippobaseAuthResetPasswordViewRoute<TServices>
    extends HttpRouteDefinition<TServices, RawResponse> {
  HippobaseAuthResetPasswordViewRoute(this.dependencies);

  final HippobaseAuthRouterDependencies dependencies;

  @override
  RouteOptions get options => const RouteOptions(operationId: 'getHippobaseAuthResetPasswordView');

  @override
  FutureOr<RawResponse> handle(RequestContext<TServices> context) {
    return RawResponse.encoded(
      status: 200,
      contentType: 'text/html; charset=utf-8',
      body: hippobaseAuthResetPasswordHtml(
        dependencies.options.appName,
        context.req.queryParam('token') ?? '',
      ),
    );
  }
}
