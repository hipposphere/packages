enum HippobaseAuthMethod { get, post, patch, delete }

final class HippobaseAuthRouteContract {
  const HippobaseAuthRouteContract({
    required this.method,
    required this.path,
    required this.operationId,
  });

  final HippobaseAuthMethod method;
  final String path;
  final String operationId;
}
