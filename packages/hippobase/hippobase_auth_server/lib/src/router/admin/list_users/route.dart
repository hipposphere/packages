import 'dart:async';
import 'package:dart_edge_core/dart_edge_core.dart';
import 'package:hippobase_auth_api_contract/hippobase_auth_api_contract.dart';
import 'package:hippobase_core_models/hippobase_core_models.dart';

import '../../../utils/route_options.dart';
import '../../../utils/route_response.dart';
import '../../dependencies.dart';
import 'pagination_query.dart';

final class HippobaseAuthAdminListUsersRoute<TServices>
    extends HttpRouteDefinition<TServices, RawResponse> {
  HippobaseAuthAdminListUsersRoute(this.dependencies);

  final HippobaseAuthRouterDependencies dependencies;

  @override
  RouteOptions get options => hippobaseAuthRouteOptions(
    HippobaseAuthRoutes.adminListUsers.operationId,
    query: paginationConfigSchema,
    queryDecoder: (values) => decodeHippobaseAuthAdminPaginationQuery(
      values,
      defaultLimit: dependencies.options.admin.defaultPageLimit,
    ),
    success: HippobaseAuthAdminListUsersResponse.response,
  );

  @override
  FutureOr<RawResponse> handle(RequestContext<TServices> context) {
    return hippobaseAuthJsonResponse(
      context,
      () async {
        final requestedPagination = context.req.maybeQuery<PaginationConfig>();
        final offset = requestedPagination?.offset ?? 0;
        final limit = requestedPagination?.limit ?? dependencies.options.admin.defaultPageLimit;
        if (offset < 0 || limit < 1 || limit > dependencies.options.admin.maxPageLimit) {
          throw const FormatException('Invalid pagination query.');
        }
        final pagination = paginationConfig(offset: offset, limit: limit);
        final users = await dependencies.repository.listUsers(limit: limit, offset: offset);
        final total = await dependencies.repository.countUsers();
        return HippobaseAuthAdminListUsersResponse(
          items: users,
          meta: paginationMetaFromConfig(config: pagination, totalItems: total),
        );
      },
      code: 'AdminListUsersFailed',
      message: 'Failed to list users.',
    );
  }
}
