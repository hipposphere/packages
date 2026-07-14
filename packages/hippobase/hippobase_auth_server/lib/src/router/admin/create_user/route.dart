import 'dart:async';

import 'package:dart_edge_core/dart_edge_core.dart';
import 'package:hippobase_auth_api_contract/hippobase_auth_api_contract.dart';

import '../../../guard.dart';
import '../../../utils/route_options.dart';
import '../../../utils/route_response.dart';
import '../../../utils/request_metadata.dart';
import '../../dependencies.dart';
import '../role.dart';

final class HippobaseAuthAdminCreateUserRoute<TServices>
    extends HttpRouteDefinition<TServices, RawResponse> {
  HippobaseAuthAdminCreateUserRoute(this.dependencies);

  final HippobaseAuthRouterDependencies dependencies;

  @override
  RouteOptions get options => hippobaseAuthRouteOptions(
    HippobaseAuthRoutes.adminCreateUser.operationId,
    body: HippobaseAuthAdminCreateUserRequest.requestBody,
    success: ResponseSpec.json(status: 201, schema: HippobaseAuthUserResponse.schema),
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
        final request = context.req.body<HippobaseAuthAdminCreateUserRequest>();
        final user = await dependencies.trustedAdmin.createUser(
          email: request.email,
          password: request.password,
          name: request.name,
          role: parseHippobaseAuthAdminRole(request.role),
          emailVerified: request.emailVerified ?? false,
        );
        return RawResponse.json(status: 201, body: HippobaseAuthUserResponse(user: user));
      },
      code: 'AdminCreateUserFailed',
      message: 'Failed to create user.',
    );
  }
}
