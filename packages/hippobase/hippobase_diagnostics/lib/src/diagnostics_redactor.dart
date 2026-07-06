import 'diagnostic_log_entry.dart';

final class DiagnosticsRedactor {
  const DiagnosticsRedactor({
    this.sensitiveKeyFragments = defaultSensitiveKeyFragments,
    this.replacement = '<redacted>',
  });

  static const List<String> defaultSensitiveKeyFragments = <String>[
    'authorization',
    'cookie',
    'password',
    'secret',
    'token',
    'apikey',
    'api_key',
    'accesskey',
    'access_key',
  ];

  static final RegExp _bearerTokenPattern = RegExp(
    r'Bearer\s+[A-Za-z0-9._~+/=-]+',
    caseSensitive: false,
  );

  final List<String> sensitiveKeyFragments;
  final String replacement;

  DiagnosticLogEntry redactEntry(DiagnosticLogEntry entry) {
    return DiagnosticLogEntry(
      id: entry.id,
      timestamp: entry.timestamp,
      level: entry.level,
      source: entry.source,
      message: redactText(entry.message),
      fields: redactFields(entry.fields),
      error: entry.error == null ? null : redactText(entry.error!),
      stackTrace: entry.stackTrace == null ? null : redactText(entry.stackTrace!),
    );
  }

  String redactText(String value) {
    return value.replaceAll(_bearerTokenPattern, replacement);
  }

  Map<String, Object?> redactFields(Map<String, Object?> fields) {
    return Map.unmodifiable(<String, Object?>{
      for (final entry in fields.entries) entry.key: _redactValue(entry.key, entry.value),
    });
  }

  Object? _redactValue(String key, Object? value) {
    if (_isSensitiveKey(key)) {
      return replacement;
    }
    return switch (value) {
      String() => redactText(value),
      Iterable<Object?>() => List<Object?>.unmodifiable(
        value.map((item) => _redactValue(key, item)),
      ),
      Map<Object?, Object?>() => Map<String, Object?>.unmodifiable(<String, Object?>{
        for (final entry in value.entries)
          entry.key.toString(): _redactValue(entry.key.toString(), entry.value),
      }),
      _ => value,
    };
  }

  bool _isSensitiveKey(String key) {
    final normalized = key.toLowerCase().replaceAll(RegExp(r'[^a-z0-9_]'), '');
    return sensitiveKeyFragments.any(normalized.contains);
  }
}
