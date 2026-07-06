import 'dart:async';
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:hippobase_diagnostics/hippobase_diagnostics.dart';

import 'log_store/default_diagnostics_store.dart';
import 'log_store/export_diagnostics_file.dart';

final class HippobaseFlutterDiagnostics {
  HippobaseFlutterDiagnostics({required this.appName, required this.store, required this.logger});

  final String appName;
  final DiagnosticsStore store;
  final DiagnosticsLogger logger;

  FlutterExceptionHandler? _previousFlutterErrorHandler;
  ui.ErrorCallback? _previousPlatformErrorHandler;
  DebugPrintCallback? _previousDebugPrint;

  static Future<HippobaseFlutterDiagnostics> create({
    required String appName,
    DiagnosticLogLevel minimumLevel = DiagnosticLogLevel.info,
    DiagnosticsRedactor redactor = const DiagnosticsRedactor(),
    int maxBytesPerFile = 5 * 1024 * 1024,
    int maxFiles = 8,
  }) async {
    final store = await createDefaultDiagnosticsStore(
      appName: appName,
      maxBytesPerFile: maxBytesPerFile,
      maxFiles: maxFiles,
    );
    final logger = DiagnosticsLogger(store: store, minimumLevel: minimumLevel, redactor: redactor);
    final diagnostics = HippobaseFlutterDiagnostics(appName: appName, store: store, logger: logger);
    logger.record(DiagnosticLogLevel.info, 'diagnostics', 'diagnostics_started');
    return diagnostics;
  }

  static Future<T> runZoned<T>({
    required String appName,
    required Future<T> Function(HippobaseFlutterDiagnostics diagnostics) body,
    DiagnosticLogLevel minimumLevel = DiagnosticLogLevel.info,
    DiagnosticsRedactor redactor = const DiagnosticsRedactor(),
    int maxBytesPerFile = 5 * 1024 * 1024,
    int maxFiles = 8,
    bool capturePrint = true,
    bool captureDebugPrint = true,
  }) async {
    HippobaseFlutterDiagnostics? diagnostics;
    final future = runZonedGuarded<Future<T>>(
      () async {
        WidgetsFlutterBinding.ensureInitialized();
        diagnostics = await HippobaseFlutterDiagnostics.create(
          appName: appName,
          minimumLevel: minimumLevel,
          redactor: redactor,
          maxBytesPerFile: maxBytesPerFile,
          maxFiles: maxFiles,
        );
        diagnostics!.installGlobalHandlers(captureDebugPrint: captureDebugPrint);
        return body(diagnostics!);
      },
      (error, stackTrace) {
        diagnostics?.logger.record(
          DiagnosticLogLevel.error,
          'dart.zone',
          'uncaught_zone_error',
          error: error,
          stackTrace: stackTrace,
        );
      },
      zoneSpecification: ZoneSpecification(
        print: capturePrint
            ? (self, parent, zone, line) {
                diagnostics?.logger.record(DiagnosticLogLevel.info, 'dart.print', line);
                parent.print(zone, line);
              }
            : null,
      ),
    );
    return await future!;
  }

  void installGlobalHandlers({bool captureDebugPrint = true}) {
    _previousFlutterErrorHandler ??= FlutterError.onError;
    FlutterError.onError = (details) {
      logger.record(
        DiagnosticLogLevel.error,
        'flutter.error',
        details.exceptionAsString(),
        fields: <String, Object?>{
          'library': details.library,
          'context': details.context?.toDescription(),
        },
        error: details.exception,
        stackTrace: details.stack,
      );
      _previousFlutterErrorHandler?.call(details);
    };

    _previousPlatformErrorHandler ??= ui.PlatformDispatcher.instance.onError;
    ui.PlatformDispatcher.instance.onError = (error, stackTrace) {
      logger.record(
        DiagnosticLogLevel.error,
        'flutter.platform_dispatcher',
        'uncaught_platform_error',
        error: error,
        stackTrace: stackTrace,
      );
      return _previousPlatformErrorHandler?.call(error, stackTrace) ?? false;
    };

    if (captureDebugPrint && _previousDebugPrint == null) {
      _previousDebugPrint = debugPrint;
      debugPrint = (message, {wrapWidth}) {
        if (message != null) {
          logger.record(DiagnosticLogLevel.debug, 'flutter.debug_print', message);
        }
        _previousDebugPrint?.call(message, wrapWidth: wrapWidth);
      };
    }
  }

  Future<String> exportLogsNdjson([
    DiagnosticLogQuery query = const DiagnosticLogQuery(newestFirst: false),
  ]) {
    return store.exportNdjson(query);
  }

  Future<String?> exportLogsToFile([
    DiagnosticLogQuery query = const DiagnosticLogQuery(newestFirst: false),
  ]) async {
    final ndjson = await exportLogsNdjson(query);
    return exportDiagnosticsNdjsonFile(appName: appName, ndjson: ndjson);
  }
}
