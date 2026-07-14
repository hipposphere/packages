import 'package:dart_edge_core/dart_edge_core.dart';

import '../../guard.dart';
import '../dependencies.dart';
import 'confirm_mail/route.dart';
import 'get_user/route.dart';
import 'info/route.dart';
import 'logout/route.dart';
import 'refresh_session/route.dart';
import 'request_password_reset/route.dart';
import 'reset_password/route.dart';
import 'sign_in_email/route.dart';
import 'sign_in_sso/route.dart';
import 'sign_up_email/route.dart';

Router<TServices> createHippobaseAuthUserRouter<TServices>(
  HippobaseAuthRouterDependencies dependencies,
) {
  final router = Router<TServices>(tags: const <String>['hippobase-auth']);
  final authGuard = HippobaseAuthGuard<TServices>(
    repository: dependencies.repository,
    tokens: dependencies.tokens,
  );

  router.routeGet('/info', HippobaseAuthInfoRoute<TServices>(dependencies));
  router.routePost('/sign-up-email', HippobaseAuthSignUpEmailRoute<TServices>(dependencies));
  router.routePost('/sign-in-email', HippobaseAuthSignInEmailRoute<TServices>(dependencies));
  router.routePost(
    '/request-password-reset',
    HippobaseAuthRequestPasswordResetRoute<TServices>(dependencies),
  );
  router.routePost('/reset-password', HippobaseAuthResetPasswordRoute<TServices>(dependencies));
  router.routePost('/confirm-mail', HippobaseAuthConfirmMailRoute<TServices>(dependencies));
  router.routePost('/sign-in-sso', HippobaseAuthSignInSsoRoute<TServices>(dependencies));
  router.routeGet(
    '/get_user',
    HippobaseAuthGetUserRoute<TServices>(dependencies),
    guards: <Guard<TServices>>[authGuard],
  );
  router.routeGet(
    '/logout',
    HippobaseAuthLogoutRoute<TServices>(dependencies),
    guards: <Guard<TServices>>[authGuard],
  );
  router.routePost(
    '/refresh-session',
    HippobaseAuthRefreshSessionRoute<TServices>(dependencies),
    guards: <Guard<TServices>>[authGuard],
  );

  return router;
}
