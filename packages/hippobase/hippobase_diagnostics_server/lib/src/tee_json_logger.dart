import 'package:dart_edge_observability/dart_edge_observability.dart';

final class TeeJsonLogger extends JsonLogger {
  const TeeJsonLogger(this.loggers);

  final List<JsonLogger> loggers;

  @override
  void log(
    LogLevel level,
    String message, {
    Map<String, Object?> fields = const <String, Object?>{},
  }) {
    for (final logger in loggers) {
      logger.log(level, message, fields: fields);
    }
  }
}
