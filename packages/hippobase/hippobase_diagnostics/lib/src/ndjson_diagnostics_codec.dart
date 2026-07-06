import 'dart:convert';

import 'diagnostic_log_entry.dart';

final class NdjsonDiagnosticsCodec {
  const NdjsonDiagnosticsCodec._();

  static String encodeEntry(DiagnosticLogEntry entry) {
    return jsonEncode(entry.toJson());
  }

  static String encodeEntries(Iterable<DiagnosticLogEntry> entries) {
    return entries.map(encodeEntry).join('\n');
  }

  static DiagnosticLogEntry? tryDecodeEntry(String line) {
    final trimmed = line.trim();
    if (trimmed.isEmpty) {
      return null;
    }
    try {
      final decoded = jsonDecode(trimmed);
      if (decoded is! Map<String, Object?>) {
        return null;
      }
      return DiagnosticLogEntry.fromJson(decoded);
    } catch (_) {
      return null;
    }
  }

  static List<DiagnosticLogEntry> decodeEntries(String ndjson) {
    return List<DiagnosticLogEntry>.unmodifiable(
      ndjson.split('\n').map(tryDecodeEntry).whereType<DiagnosticLogEntry>(),
    );
  }
}
