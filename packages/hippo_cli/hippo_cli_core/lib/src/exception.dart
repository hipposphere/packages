final class HippoExitCode {
  const HippoExitCode._();

  static const ok = 0;
  static const software = 1;
  static const usage = 64;
  static const unavailable = 69;
  static const config = 78;
}

final class HippoException implements Exception {
  const HippoException(
    this.message, {
    this.expected,
    this.nextSteps = const [],
    this.exitCode = HippoExitCode.software,
  });

  final String message;
  final String? expected;
  final List<String> nextSteps;
  final int exitCode;

  @override
  String toString() => message;
}
