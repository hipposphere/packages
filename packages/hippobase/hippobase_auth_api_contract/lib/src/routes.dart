import 'admin/create_user.dart';
import 'admin/delete_user.dart';
import 'admin/list_users.dart';
import 'admin/update_user.dart';
import 'oauth2/callback.dart';
import 'oauth2/sign_in.dart';
import 'shared/route_contract.dart';
import 'user/confirm_mail.dart';
import 'user/get_user.dart';
import 'user/info.dart';
import 'user/logout.dart';
import 'user/refresh_session.dart';
import 'user/request_password_reset.dart';
import 'user/reset_password.dart';
import 'user/sign_in_email.dart';
import 'user/sign_in_sso.dart';
import 'user/sign_up_email.dart';

abstract final class HippobaseAuthRoutes {
  static const info = hippobaseAuthInfoRoute;
  static const confirmMail = hippobaseAuthConfirmMailRoute;
  static const requestPasswordReset = hippobaseAuthRequestPasswordResetRoute;
  static const resetPassword = hippobaseAuthResetPasswordRoute;
  static const signInEmail = hippobaseAuthSignInEmailRoute;
  static const signUpEmail = hippobaseAuthSignUpEmailRoute;
  static const signInSso = hippobaseAuthSignInSsoRoute;
  static const getUser = hippobaseAuthGetUserRoute;
  static const logout = hippobaseAuthLogoutRoute;
  static const refreshSession = hippobaseAuthRefreshSessionRoute;
  static const oauthSignIn = hippobaseAuthOAuthSignInRoute;
  static const oauthCallback = hippobaseAuthOAuthCallbackRoute;
  static const adminCreateUser = hippobaseAuthAdminCreateUserRoute;
  static const adminListUsers = hippobaseAuthAdminListUsersRoute;
  static const adminUpdateUser = hippobaseAuthAdminUpdateUserRoute;
  static const adminDeleteUser = hippobaseAuthAdminDeleteUserRoute;

  static const publicRoutes = <HippobaseAuthRouteContract>[
    info,
    confirmMail,
    requestPasswordReset,
    resetPassword,
    signInEmail,
    signUpEmail,
    signInSso,
    getUser,
    logout,
    refreshSession,
    oauthSignIn,
    oauthCallback,
  ];

  static const adminRoutes = <HippobaseAuthRouteContract>[
    adminCreateUser,
    adminListUsers,
    adminUpdateUser,
    adminDeleteUser,
  ];
}
