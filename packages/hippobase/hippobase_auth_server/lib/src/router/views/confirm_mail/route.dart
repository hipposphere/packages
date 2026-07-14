import 'dart:async';

import 'package:dart_edge_core/dart_edge_core.dart';

import '../../dependencies.dart';
import '../html.dart';

final class HippobaseAuthConfirmMailViewRoute<TServices>
    extends HttpRouteDefinition<TServices, RawResponse> {
  HippobaseAuthConfirmMailViewRoute(this.dependencies);

  final HippobaseAuthRouterDependencies dependencies;

  @override
  RouteOptions get options => const RouteOptions(operationId: 'getHippobaseAuthConfirmMailView');

  @override
  FutureOr<RawResponse> handle(RequestContext<TServices> context) {
    return RawResponse.encoded(
      status: 200,
      contentType: 'text/html; charset=utf-8',
      body: hippobaseAuthConfirmMailHtml(
        dependencies.options.appName,
        context.req.queryParam('token') ?? '',
      ),
    );
  }
}
