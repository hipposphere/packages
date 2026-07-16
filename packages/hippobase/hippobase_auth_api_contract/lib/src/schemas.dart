import 'package:hippobase_auth_models/hippobase_auth_models.dart';
import 'package:hippobase_core_models/hippobase_core_models.dart';
import 'package:json_schema/json_schema.dart';

import 'admin/create_user.dart';
import 'admin/delete_user.dart';
import 'admin/list_users.dart';
import 'admin/update_user.dart';
import 'oauth2/callback.dart';
import 'oauth2/sign_in.dart';
import 'shared/error.dart';
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

const hippobaseAuthContractSchemas = JsonSchemaRegistry(
  schemas: <JsonSchema>[
    AuthUserRow.jsonSchema,
    hippobaseAuthErrorSchema,
    hippobaseAuthSsoProviderSchema,
    hippobaseAuthInfoResponseSchema,
    hippobaseAuthSessionPayloadSchema,
    hippobaseAuthUserResponseSchema,
    signInEmailRequestSchema,
    signUpEmailRequestSchema,
    emailRequestSchema,
    tokenRequestSchema,
    resetPasswordRequestSchema,
    successResponseSchema,
    refreshSessionResponseSchema,
    signInSsoRequestSchema,
    signInSsoResponseSchema,
    oauthSignInParamsSchema,
    oauthSignInQuerySchema,
    oauthCallbackQuerySchema,
    adminCreateUserRequestSchema,
    adminUpdateUserParamsSchema,
    adminUpdateUserRequestSchema,
    adminDeleteUserParamsSchema,
    adminDeleteUserResponseSchema,
    paginationConfigSchema,
    paginationMetaSchema,
    adminListUsersResponseSchema,
    hippobaseAuthLogoutResponseSchema,
  ],
);
