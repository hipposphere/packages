import 'package:dart_edge_core/dart_edge_core.dart';

import 'auth_controller.dart';

typedef HippobaseAuthClientSend =
    Future<DartEdgeClientResponse> Function(DartEdgeClientRequest request);

/// Adds the current user session token to Dart Edge client requests.
final class HippobaseAuthAuthorizationInterceptor {
  const HippobaseAuthAuthorizationInterceptor(this.controller);

  final HippobaseAuthController controller;

  Future<DartEdgeClientResponse> call(
    DartEdgeClientRequest request,
    HippobaseAuthClientSend next,
  ) async {
    if (request.headers.keys.any((header) => header.toLowerCase() == 'authorization')) {
      return next(request);
    }
    final token = await controller.authorizationToken();
    if (token == null) return next(request);
    return next(
      request.copyWith(
        headers: <String, String>{...request.headers, 'authorization': 'Bearer $token'},
      ),
    );
  }
}
