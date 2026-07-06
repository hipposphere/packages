import 'dart:async';

import 'diagnostic_log_entry.dart';
import 'diagnostic_log_level.dart';
import 'diagnostics_redactor.dart';
import 'diagnostics_store.dart';

final class DiagnosticsLogger {
  DiagnosticsLogger({
    required this.store,
    this.minimumLevel = DiagnosticLogLevel.info,
    this.redactor = const DiagnosticsRedactor(),
    DateTime Function()? clock,
  }) : _clock = clock ?? DateTime.now;

  final DiagnosticsStore store;
  final DiagnosticLogLevel minimumLevel;
  final DiagnosticsRedactor redactor;
  final DateTime Function() _clock;
  var _sequence = 0;

  Future<void> log(
    DiagnosticLogLevel level,
    String source,
    String message, {
    Map<String, Object?> fields = const <String, Object?>{},
    Object? error,
    StackTrace? stackTrace,
  }) async {
    if (!minimumLevel.allows(level)) {
      return;
    }
    final timestamp = _clock().toUtc();
    final sequence = _sequence++;
    final entry = DiagnosticLogEntry.create(
      id: '${timestamp.microsecondsSinceEpoch}-$sequence',
      timestamp: timestamp,
      level: level,
      source: source,
      message: message,
      fields: fields,
      error: error,
      stackTrace: stackTrace,
    );
    await store.append(redactor.redactEntry(entry));
  }

  void record(
    DiagnosticLogLevel level,
    String source,
    String message, {
    Map<String, Object?> fields = const <String, Object?>{},
    Object? error,
    StackTrace? stackTrace,
  }) {
    unawaited(log(level, source, message, fields: fields, error: error, stackTrace: stackTrace));
  }

  Future<void> debug(String source, String message, {Map<String, Object?> fields = const {}}) {
    return log(DiagnosticLogLevel.debug, source, message, fields: fields);
  }

  Future<void> info(String source, String message, {Map<String, Object?> fields = const {}}) {
    return log(DiagnosticLogLevel.info, source, message, fields: fields);
  }

  Future<void> warning(
    String source,
    String message, {
    Map<String, Object?> fields = const {},
    Object? error,
    StackTrace? stackTrace,
  }) {
    return log(
      DiagnosticLogLevel.warning,
      source,
      message,
      fields: fields,
      error: error,
      stackTrace: stackTrace,
    );
  }

  Future<void> error(
    String source,
    String message, {
    Map<String, Object?> fields = const {},
    Object? error,
    StackTrace? stackTrace,
  }) {
    return log(
      DiagnosticLogLevel.error,
      source,
      message,
      fields: fields,
      error: error,
      stackTrace: stackTrace,
    );
  }
}
