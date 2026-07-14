import 'package:dart_edge_core/dart_edge_core.dart';

import '../dependencies.dart';
import 'callback/route.dart';
import 'sign_in/route.dart';

Router<TServices> createHippobaseAuthOAuth2Router<TServices>(
  HippobaseAuthRouterDependencies dependencies,
) {
  final router = Router<TServices>(tags: const <String>['hippobase-auth']);

  router.routeGet('/sign-in/<providerId>', HippobaseAuthOAuth2SignInRoute<TServices>(dependencies));
  router.routeGet(
    '/callback/<providerId>',
    HippobaseAuthOAuth2CallbackRoute<TServices>(dependencies),
  );

  return router;
}
