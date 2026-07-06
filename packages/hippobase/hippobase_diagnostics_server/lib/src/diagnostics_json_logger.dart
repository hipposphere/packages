import 'package:dart_edge_observability/dart_edge_observability.dart';
import 'package:hippobase_diagnostics/hippobase_diagnostics.dart';

final class DiagnosticsJsonLogger extends JsonLogger {
  const DiagnosticsJsonLogger({required this.logger, this.source = 'dart_edge'});

  final DiagnosticsLogger logger;
  final String source;

  @override
  void log(
    LogLevel level,
    String message, {
    Map<String, Object?> fields = const <String, Object?>{},
  }) {
    logger.record(_toDiagnosticLogLevel(level), source, message, fields: fields);
  }
}

DiagnosticLogLevel _toDiagnosticLogLevel(LogLevel level) {
  return switch (level) {
    LogLevel.debug => DiagnosticLogLevel.debug,
    LogLevel.info => DiagnosticLogLevel.info,
    LogLevel.warning => DiagnosticLogLevel.warning,
    LogLevel.error => DiagnosticLogLevel.error,
  };
}
