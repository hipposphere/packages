/// API contracts for Hippobase Auth.
library;

export 'package:hippobase_core_models/hippobase_core_models.dart'
    show PaginationConfig, PaginationMeta, paginationConfig, paginationMetaFromConfig;

export 'src/admin/create_user.dart';
export 'src/admin/delete_user.dart';
export 'src/admin/list_users.dart';
export 'src/admin/update_user.dart';
export 'src/oauth2/callback.dart';
export 'src/oauth2/sign_in.dart';
export 'src/routes.dart';
export 'src/schemas.dart';
export 'src/shared/error.dart';
export 'src/shared/route_contract.dart';
export 'src/user/confirm_mail.dart';
export 'src/user/get_user.dart';
export 'src/user/info.dart';
export 'src/user/logout.dart';
export 'src/user/refresh_session.dart';
export 'src/user/request_password_reset.dart';
export 'src/user/reset_password.dart';
export 'src/user/sign_in_email.dart';
export 'src/user/sign_in_sso.dart';
export 'src/user/sign_up_email.dart';
