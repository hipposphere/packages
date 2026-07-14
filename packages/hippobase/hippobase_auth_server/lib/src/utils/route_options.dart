import 'package:dart_edge_core/dart_edge_core.dart';

RouteOptions hippobaseAuthRouteOptions(
  String operationId, {
  RequestBody? body,
  JsonSchema? params,
  RequestValueDecoder? paramsDecoder,
  JsonSchema? query,
  RequestValueDecoder? queryDecoder,
  ResponseSpec? success,
}) {
  return RouteOptions(
    operationId: operationId,
    body: body,
    params: params,
    paramsDecoder: paramsDecoder,
    query: query,
    queryDecoder: queryDecoder,
    success: success,
    errors: const <ErrorResponse>[
      ErrorResponse(status: 400, code: 'InvalidRequest'),
      ErrorResponse(status: 401, code: 'Unauthorized'),
      ErrorResponse(status: 403, code: 'Forbidden'),
      ErrorResponse(status: 429, code: 'RateLimited'),
      ErrorResponse(status: 500, code: 'AuthFailed'),
    ],
  );
}
