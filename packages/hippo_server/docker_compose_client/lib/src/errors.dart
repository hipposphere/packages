final class DockerComposeException implements Exception {
  const DockerComposeException({
    required this.message,
    required this.arguments,
    required this.exitCode,
    required this.stdout,
    required this.stderr,
  });

  final String message;
  final List<String> arguments;
  final int exitCode;
  final String stdout;
  final String stderr;

  @override
  String toString() => 'DockerComposeException($exitCode): $message';
}

final class DockerComposeTimeoutException implements Exception {
  const DockerComposeTimeoutException({required this.arguments, required this.timeout});

  final List<String> arguments;
  final Duration timeout;

  @override
  String toString() =>
      'DockerComposeTimeoutException: command exceeded ${timeout.inMilliseconds}ms.';
}
