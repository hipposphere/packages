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

final class HippobaseAuthAdminDeleteUserRoute<TServices>
    extends HttpRouteDefinition<TServices, RawResponse> {
  HippobaseAuthAdminDeleteUserRoute(this.dependencies);

  final HippobaseAuthRouterDependencies dependencies;

  @override
  RouteOptions get options => hippobaseAuthRouteOptions(
    HippobaseAuthRoutes.adminDeleteUser.operationId,
    params: adminDeleteUserParamsSchema,
    success: HippobaseAuthAdminDeleteUserResponse.response,
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
            'AdminDeleteUserInvalidRequest',
            'A user ID must be provided.',
          );
        }
        final success = await dependencies.trustedAdmin.deleteUser(AuthUserId(userId));
        return HippobaseAuthAdminDeleteUserResponse(success: success, userId: userId);
      },
      code: 'AdminDeleteUserFailed',
      message: 'Failed to delete user.',
    );
  }
}
