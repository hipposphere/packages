final class HippobaseAuthApiException implements Exception {
  const HippobaseAuthApiException({
    required this.status,
    required this.code,
    required this.message,
    this.details,
  });

  final int status;
  final String code;
  final String message;
  final Map<String, Object?>? details;

  @override
  String toString() => 'HippobaseAuthApiException($status, $code, $message)';
}
