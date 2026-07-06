import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:hippobase_diagnostics/hippobase_diagnostics.dart';

import 'flutter_diagnostics.dart';

final class DiagnosticsLogController extends ChangeNotifier {
  DiagnosticsLogController({
    required this.diagnostics,
    DiagnosticLogQuery initialQuery = const DiagnosticLogQuery(limit: 500),
    bool autoRefresh = true,
  }) : _query = initialQuery {
    if (autoRefresh) {
      startAutoRefresh();
    }
  }

  final HippobaseFlutterDiagnostics diagnostics;

  DiagnosticLogQuery _query;
  List<DiagnosticLogEntry> _entries = const <DiagnosticLogEntry>[];
  bool _isLoading = false;
  bool _isExporting = false;
  Object? _error;
  StackTrace? _stackTrace;
  StreamSubscription<DiagnosticLogEntry>? _entrySubscription;

  DiagnosticLogQuery get query => _query;
  List<DiagnosticLogEntry> get entries => _entries;
  bool get isLoading => _isLoading;
  bool get isExporting => _isExporting;
  Object? get error => _error;
  StackTrace? get stackTrace => _stackTrace;

  void startAutoRefresh() {
    _entrySubscription ??= diagnostics.store.entries.listen((_) {
      unawaited(load());
    });
  }

  void stopAutoRefresh() {
    unawaited(_entrySubscription?.cancel());
    _entrySubscription = null;
  }

  void updateQuery(DiagnosticLogQuery query) {
    _query = query;
    notifyListeners();
    unawaited(load());
  }

  Future<void> load() async {
    _isLoading = true;
    _error = null;
    _stackTrace = null;
    notifyListeners();
    try {
      _entries = await diagnostics.store.query(_query);
    } catch (error, stackTrace) {
      _error = error;
      _stackTrace = stackTrace;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> clear() async {
    _isLoading = true;
    _error = null;
    _stackTrace = null;
    notifyListeners();
    try {
      await diagnostics.store.clear();
      _entries = const <DiagnosticLogEntry>[];
    } catch (error, stackTrace) {
      _error = error;
      _stackTrace = stackTrace;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<DiagnosticsLogExportResult?> export() async {
    _isExporting = true;
    _error = null;
    _stackTrace = null;
    notifyListeners();
    try {
      final path = await diagnostics.exportLogsToFile(_query);
      if (path != null) {
        return DiagnosticsLogFileExportResult(path);
      }
      return DiagnosticsLogTextExportResult(await diagnostics.exportLogsNdjson(_query));
    } catch (error, stackTrace) {
      _error = error;
      _stackTrace = stackTrace;
      return null;
    } finally {
      _isExporting = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    stopAutoRefresh();
    super.dispose();
  }
}

sealed class DiagnosticsLogExportResult {
  const DiagnosticsLogExportResult();
}

final class DiagnosticsLogFileExportResult extends DiagnosticsLogExportResult {
  const DiagnosticsLogFileExportResult(this.path);

  final String path;
}

final class DiagnosticsLogTextExportResult extends DiagnosticsLogExportResult {
  const DiagnosticsLogTextExportResult(this.ndjson);

  final String ndjson;
}
