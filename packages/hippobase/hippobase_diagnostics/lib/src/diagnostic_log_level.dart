enum DiagnosticLogLevel {
  debug,
  info,
  warning,
  error;

  static DiagnosticLogLevel? parse(String? value) {
    return switch (value?.trim().toLowerCase()) {
      'debug' => DiagnosticLogLevel.debug,
      'info' => DiagnosticLogLevel.info,
      'warn' || 'warning' => DiagnosticLogLevel.warning,
      'error' => DiagnosticLogLevel.error,
      _ => null,
    };
  }

  bool allows(DiagnosticLogLevel level) {
    return level.index >= index;
  }
}
