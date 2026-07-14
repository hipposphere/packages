import 'dart:async';

import 'package:dart_edge_core/dart_edge_core.dart';
import 'package:hippobase_auth_api_contract/hippobase_auth_api_contract.dart';
import 'package:hippobase_auth_models/hippobase_auth_models.dart';

import '../../../error.dart';
import '../../../guard.dart';
import '../../../utils/route_options.dart';
import '../../../utils/route_response.dart';
import '../../../utils/request_metadata.dart';
import '../../dependencies.dart';
import '../role.dart';

final class HippobaseAuthAdminUpdateUserRoute<TServices>
    extends HttpRouteDefinition<TServices, RawResponse> {
  HippobaseAuthAdminUpdateUserRoute(this.dependencies);

  final HippobaseAuthRouterDependencies dependencies;

  @override
  RouteOptions get options => hippobaseAuthRouteOptions(
    HippobaseAuthRoutes.adminUpdateUser.operationId,
    params: adminUpdateUserParamsSchema,
    body: HippobaseAuthAdminUpdateUserRequest.requestBody,
    success: HippobaseAuthUserResponse.response,
  );

  @override
  FutureOr<RawResponse> handle(RequestContext<TServices> context) {
    return hippobaseAuthJsonResponse(
      context,
      () async {
        dependencies.service.ensureTrustedOrigin(
          hippobaseAuthRequestMetadata(context),
          identity: context.requireHippobaseAuthIdentity,
        );
        final userId = context.req.param('userId');
        if (userId == null) {
          throw const HippobaseAuthException(
            400,
            'AdminUpdateUserInvalidRequest',
            'A user ID must be provided.',
          );
        }
        final request = context.req.body<HippobaseAuthAdminUpdateUserRequest>();
        final role = parseHippobaseAuthAdminRole(request.role)!;
        final user = await dependencies.trustedAdmin.updateUserRole(
          userId: AuthUserId(userId),
          role: role,
        );
        return HippobaseAuthUserResponse(user: user);
      },
      code: 'AdminUpdateUserFailed',
      message: 'Failed to update user.',
    );
  }
}
