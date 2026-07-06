import 'dart:async';

import 'diagnostic_log_entry.dart';
import 'diagnostic_log_query.dart';
import 'diagnostics_store.dart';

final class InMemoryDiagnosticsStore implements DiagnosticsStore {
  InMemoryDiagnosticsStore({this.maxEntries = 1000});

  final int maxEntries;
  final List<DiagnosticLogEntry> _entries = <DiagnosticLogEntry>[];
  final StreamController<DiagnosticLogEntry> _controller =
      StreamController<DiagnosticLogEntry>.broadcast();

  @override
  Stream<DiagnosticLogEntry> get entries => _controller.stream;

  @override
  Future<void> append(DiagnosticLogEntry entry) async {
    _entries.add(entry);
    if (_entries.length > maxEntries) {
      _entries.removeRange(0, _entries.length - maxEntries);
    }
    _controller.add(entry);
  }

  @override
  Future<void> clear() async {
    _entries.clear();
  }

  @override
  Future<List<DiagnosticLogEntry>> query([
    DiagnosticLogQuery query = const DiagnosticLogQuery(),
  ]) async {
    return query.apply(_entries);
  }

  Future<void> close() async {
    await _controller.close();
  }
}
