import 'diagnostic_log_entry.dart';
import 'diagnostic_log_query.dart';
import 'diagnostics_store.dart';

final class FileDiagnosticsStore implements DiagnosticsStore {
  FileDiagnosticsStore({
    required String directoryPath,
    required String filePrefix,
    int maxBytesPerFile = 5 * 1024 * 1024,
    int maxFiles = 8,
  }) {
    throw UnsupportedError('FileDiagnosticsStore is only available on native IO platforms.');
  }

  @override
  Stream<DiagnosticLogEntry> get entries => const Stream<DiagnosticLogEntry>.empty();

  @override
  Future<void> append(DiagnosticLogEntry entry) {
    throw UnsupportedError('FileDiagnosticsStore is only available on native IO platforms.');
  }

  @override
  Future<void> clear() {
    throw UnsupportedError('FileDiagnosticsStore is only available on native IO platforms.');
  }

  @override
  Future<List<DiagnosticLogEntry>> query([DiagnosticLogQuery query = const DiagnosticLogQuery()]) {
    throw UnsupportedError('FileDiagnosticsStore is only available on native IO platforms.');
  }
}
