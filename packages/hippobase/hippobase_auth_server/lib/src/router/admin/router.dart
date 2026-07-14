import 'package:dart_edge_core/dart_edge_core.dart';

import '../../guard.dart';
import '../dependencies.dart';
import 'create_user/route.dart';
import 'delete_user/route.dart';
import 'list_users/route.dart';
import 'update_user/route.dart';

Router<TServices> createHippobaseAuthAdminRouter<TServices>(
  HippobaseAuthRouterDependencies dependencies, {
  Guard<TServices>? guard,
}) {
  final authGuard = HippobaseAuthGuard<TServices>(
    repository: dependencies.repository,
    tokens: dependencies.tokens,
    allowedRoles: guard == null ? dependencies.options.admin.normalizedAdminRoles : null,
  );
  final guards = <Guard<TServices>>[authGuard, ?guard];
  final router = Router<TServices>(tags: const <String>['hippobase-auth-admin'], guards: guards);

  router.routePost('/users', HippobaseAuthAdminCreateUserRoute<TServices>(dependencies));
  router.routeGet('/users', HippobaseAuthAdminListUsersRoute<TServices>(dependencies));
  router.routePatch('/users/<userId>', HippobaseAuthAdminUpdateUserRoute<TServices>(dependencies));
  router.routeDelete('/users/<userId>', HippobaseAuthAdminDeleteUserRoute<TServices>(dependencies));

  return router;
}
