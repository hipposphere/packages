import 'dart:convert';

import 'diagnostic_log_entry.dart';
import 'diagnostic_log_level.dart';

final class DiagnosticLogQuery {
  const DiagnosticLogQuery({
    this.text,
    this.levels = const <DiagnosticLogLevel>{},
    this.sources = const <String>{},
    this.sourcePrefix,
    this.from,
    this.until,
    this.limit,
    this.newestFirst = true,
  });

  final String? text;
  final Set<DiagnosticLogLevel> levels;
  final Set<String> sources;
  final String? sourcePrefix;
  final DateTime? from;
  final DateTime? until;
  final int? limit;
  final bool newestFirst;

  bool matches(DiagnosticLogEntry entry) {
    if (levels.isNotEmpty && !levels.contains(entry.level)) {
      return false;
    }
    if (sources.isNotEmpty && !sources.contains(entry.source)) {
      return false;
    }
    final prefix = sourcePrefix;
    if (prefix != null && prefix.isNotEmpty && !entry.source.startsWith(prefix)) {
      return false;
    }
    final lowerText = text?.trim().toLowerCase();
    if (lowerText != null && lowerText.isNotEmpty && !_searchText(entry).contains(lowerText)) {
      return false;
    }
    final fromValue = from;
    if (fromValue != null && entry.timestamp.isBefore(fromValue)) {
      return false;
    }
    final untilValue = until;
    if (untilValue != null && entry.timestamp.isAfter(untilValue)) {
      return false;
    }
    return true;
  }

  List<DiagnosticLogEntry> apply(Iterable<DiagnosticLogEntry> entries) {
    final filtered = entries.where(matches).toList()
      ..sort((a, b) {
        final comparison = a.timestamp.compareTo(b.timestamp);
        return newestFirst ? -comparison : comparison;
      });
    final limitValue = limit;
    if (limitValue == null || filtered.length <= limitValue) {
      return List<DiagnosticLogEntry>.unmodifiable(filtered);
    }
    return List<DiagnosticLogEntry>.unmodifiable(filtered.take(limitValue));
  }
}

String _searchText(DiagnosticLogEntry entry) {
  return <String>[
    entry.level.name,
    entry.source,
    entry.message,
    if (entry.error != null) entry.error!,
    if (entry.stackTrace != null) entry.stackTrace!,
    if (entry.fields.isNotEmpty) jsonEncode(entry.fields),
  ].join('\n').toLowerCase();
}
