import 'diagnostic_log_entry.dart';
import 'diagnostic_log_query.dart';
import 'ndjson_diagnostics_codec.dart';

abstract interface class DiagnosticsStore {
  Future<void> append(DiagnosticLogEntry entry);

  Future<List<DiagnosticLogEntry>> query([DiagnosticLogQuery query = const DiagnosticLogQuery()]);

  Future<void> clear();

  Stream<DiagnosticLogEntry> get entries;
}

extension DiagnosticsStoreExport on DiagnosticsStore {
  Future<String> exportNdjson([
    DiagnosticLogQuery query = const DiagnosticLogQuery(newestFirst: false),
  ]) async {
    return NdjsonDiagnosticsCodec.encodeEntries(await this.query(query));
  }
}
