import 'package:dart_edge_core/dart_edge_core.dart';

import '../dependencies.dart';
import 'confirm_mail/route.dart';
import 'reset_password/route.dart';

Router<TServices> createHippobaseAuthViewsRouter<TServices>(
  HippobaseAuthRouterDependencies dependencies,
) {
  final router = Router<TServices>(tags: const <String>['hippobase-auth-views']);
  router.routeGet('/reset-password', HippobaseAuthResetPasswordViewRoute<TServices>(dependencies));
  router.routeGet('/confirm-mail', HippobaseAuthConfirmMailViewRoute<TServices>(dependencies));
  return router;
}
