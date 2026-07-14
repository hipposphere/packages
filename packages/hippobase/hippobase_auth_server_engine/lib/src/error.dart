final class HippobaseAuthException implements Exception {
  const HippobaseAuthException(this.status, this.code, this.message, {this.details});

  final int status;
  final String code;
  final String message;
  final Map<String, Object?>? details;
}
