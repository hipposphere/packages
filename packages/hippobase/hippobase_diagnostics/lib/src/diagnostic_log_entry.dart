import 'diagnostic_log_level.dart';

final class DiagnosticLogEntry {
  const DiagnosticLogEntry({
    required this.id,
    required this.timestamp,
    required this.level,
    required this.source,
    required this.message,
    this.fields = const <String, Object?>{},
    this.error,
    this.stackTrace,
  });

  factory DiagnosticLogEntry.create({
    required DiagnosticLogLevel level,
    required String source,
    required String message,
    Map<String, Object?> fields = const <String, Object?>{},
    Object? error,
    StackTrace? stackTrace,
    DateTime? timestamp,
    String? id,
  }) {
    final effectiveTimestamp = (timestamp ?? DateTime.now()).toUtc();
    return DiagnosticLogEntry(
      id: id ?? '${effectiveTimestamp.microsecondsSinceEpoch}',
      timestamp: effectiveTimestamp,
      level: level,
      source: source,
      message: message,
      fields: normalizeDiagnosticFields(fields),
      error: error?.toString(),
      stackTrace: stackTrace?.toString(),
    );
  }

  final String id;
  final DateTime timestamp;
  final DiagnosticLogLevel level;
  final String source;
  final String message;
  final Map<String, Object?> fields;
  final String? error;
  final String? stackTrace;

  Map<String, Object?> toJson() {
    return <String, Object?>{
      'id': id,
      'timestamp': timestamp.toUtc().toIso8601String(),
      'level': level.name,
      'source': source,
      'message': message,
      if (fields.isNotEmpty) 'fields': fields,
      if (error != null) 'error': error,
      if (stackTrace != null) 'stackTrace': stackTrace,
    };
  }

  static DiagnosticLogEntry fromJson(Map<String, Object?> json) {
    final rawFields = json['fields'];
    return DiagnosticLogEntry(
      id: json['id']?.toString() ?? '',
      timestamp: DateTime.parse(json['timestamp'].toString()).toUtc(),
      level: DiagnosticLogLevel.parse(json['level']?.toString()) ?? DiagnosticLogLevel.info,
      source: json['source']?.toString() ?? 'unknown',
      message: json['message']?.toString() ?? '',
      fields: normalizeDiagnosticFields(
        rawFields is Map ? Map<String, Object?>.from(rawFields) : const <String, Object?>{},
      ),
      error: json['error']?.toString(),
      stackTrace: json['stackTrace']?.toString(),
    );
  }
}

Map<String, Object?> normalizeDiagnosticFields(Map<String, Object?> fields) {
  return Map.unmodifiable(<String, Object?>{
    for (final entry in fields.entries) entry.key: normalizeDiagnosticValue(entry.value),
  });
}

Object? normalizeDiagnosticValue(Object? value) {
  return switch (value) {
    null || bool() || num() || String() => value,
    DateTime() => value.toUtc().toIso8601String(),
    Iterable<Object?>() => List<Object?>.unmodifiable(value.map(normalizeDiagnosticValue)),
    Map<Object?, Object?>() => Map<String, Object?>.unmodifiable(<String, Object?>{
      for (final entry in value.entries)
        entry.key.toString(): normalizeDiagnosticValue(entry.value),
    }),
    _ => value.toString(),
  };
}
