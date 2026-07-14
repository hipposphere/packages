import 'package:dart_edge_core/dart_edge_core.dart';

import 'admin/router.dart';
import 'dependencies.dart';
import 'oauth2/router.dart';
import 'user/router.dart';
import 'views/router.dart';

void mountHippobaseAuthPublicRouter<TServices>(
  Router<TServices> router, {
  required HippobaseAuthRouterDependencies dependencies,
  String basePath = '',
}) {
  final target = hippobaseAuthTargetRouter(router, basePath);
  target.mountRouter('/v1/user', createHippobaseAuthUserRouter(dependencies));
  target.mountRouter('/v1/oauth2', createHippobaseAuthOAuth2Router(dependencies));
  if (dependencies.options.hostedViews) {
    target.mountRouter('/views', createHippobaseAuthViewsRouter(dependencies));
  }
}

void mountHippobaseAuthAdminRouter<TServices>(
  Router<TServices> router, {
  required HippobaseAuthRouterDependencies dependencies,
  String basePath = '',
  Guard<TServices>? guard,
}) {
  final target = hippobaseAuthTargetRouter(router, basePath);
  target.mountRouter('/v1/admin', createHippobaseAuthAdminRouter(dependencies, guard: guard));
}

Router<TServices> hippobaseAuthTargetRouter<TServices>(Router<TServices> router, String basePath) {
  var path = basePath.trim();
  if (path.isEmpty || path == '/') return router;
  if (!path.startsWith('/')) path = '/$path';
  while (path.endsWith('/') && path.length > 1) {
    path = path.substring(0, path.length - 1);
  }
  return router.router(path);
}
