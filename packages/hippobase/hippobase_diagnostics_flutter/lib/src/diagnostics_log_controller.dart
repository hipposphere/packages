import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:hippobase_diagnostics/hippobase_diagnostics.dart';

import 'flutter_diagnostics.dart';

final class DiagnosticsLogController extends ChangeNotifier {
  DiagnosticsLogController({
    required this.diagnostics,
    DiagnosticLogQuery initialQuery = const DiagnosticLogQuery(limit: 500),
    bool autoRefresh = true,
    this.autoRefreshDebounce = const Duration(milliseconds: 250),
  }) : _query = initialQuery {
    if (autoRefresh) {
      startAutoRefresh();
    }
  }

  final HippobaseFlutterDiagnostics diagnostics;
  final Duration autoRefreshDebounce;

  DiagnosticLogQuery _query;
  List<DiagnosticLogEntry> _entries = const <DiagnosticLogEntry>[];
  bool _isLoading = false;
  bool _isExporting = false;
  Object? _error;
  StackTrace? _stackTrace;
  StreamSubscription<DiagnosticLogEntry>? _entrySubscription;
  Timer? _autoRefreshTimer;
  Future<void>? _loadFuture;
  bool _loadRequested = false;
  bool _isDisposed = false;

  DiagnosticLogQuery get query => _query;
  List<DiagnosticLogEntry> get entries => _entries;
  bool get isLoading => _isLoading;
  bool get isExporting => _isExporting;
  Object? get error => _error;
  StackTrace? get stackTrace => _stackTrace;

  void startAutoRefresh() {
    _entrySubscription ??= diagnostics.store.entries.listen((_) {
      _scheduleAutoRefresh();
    });
  }

  void stopAutoRefresh() {
    _autoRefreshTimer?.cancel();
    _autoRefreshTimer = null;
    unawaited(_entrySubscription?.cancel());
    _entrySubscription = null;
  }

  void updateQuery(DiagnosticLogQuery query) {
    _query = query;
    _notifyListeners();
    unawaited(load());
  }

  Future<void> load() async {
    if (_isDisposed) {
      return;
    }
    final loadFuture = _loadFuture;
    if (loadFuture != null) {
      _loadRequested = true;
      return loadFuture;
    }
    final future = _loadUntilSettled();
    _loadFuture = future;
    try {
      await future;
    } finally {
      if (identical(_loadFuture, future)) {
        _loadFuture = null;
      }
    }
  }

  Future<void> _loadUntilSettled() async {
    _isLoading = true;
    _error = null;
    _stackTrace = null;
    _notifyListeners();
    try {
      do {
        _loadRequested = false;
        final entries = await diagnostics.store.query(_query);
        if (_isDisposed) {
          return;
        }
        _entries = entries;
      } while (_loadRequested && !_isDisposed);
    } catch (error, stackTrace) {
      _error = error;
      _stackTrace = stackTrace;
    } finally {
      if (!_isDisposed) {
        _isLoading = false;
        _notifyListeners();
      }
    }
  }

  Future<void> clear() async {
    _isLoading = true;
    _error = null;
    _stackTrace = null;
    _notifyListeners();
    try {
      await diagnostics.store.clear();
      _entries = const <DiagnosticLogEntry>[];
    } catch (error, stackTrace) {
      _error = error;
      _stackTrace = stackTrace;
    } finally {
      _isLoading = false;
      _notifyListeners();
    }
  }

  Future<DiagnosticsLogExportResult?> export() async {
    _isExporting = true;
    _error = null;
    _stackTrace = null;
    _notifyListeners();
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
      _notifyListeners();
    }
  }

  void _scheduleAutoRefresh() {
    if (_isDisposed) {
      return;
    }
    _autoRefreshTimer?.cancel();
    _autoRefreshTimer = Timer(autoRefreshDebounce, () {
      _autoRefreshTimer = null;
      unawaited(load());
    });
  }

  void _notifyListeners() {
    if (!_isDisposed) {
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _isDisposed = true;
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
