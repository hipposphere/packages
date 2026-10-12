import 'dart:convert';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

/// A named rendering configuration; deliberately no implicit Cartesian product.
class FeatureVariant {
  const FeatureVariant(
    this.name, {
    this.size = const Size(390, 844),
    this.brightness = Brightness.light,
    this.locale = const Locale('en'),
    this.textScale = 1,
  });

  final String name;
  final Size size;
  final Brightness brightness;
  final Locale locale;
  final double textScale;
}

/// Register one independently runnable scenario using Flutter's test runner.
///
/// IDs must be unique across a run. [kind] describes the actual boundary tested,
/// for example `feature`, `feature-integration`, or `end-to-end`.
void featureTest(
  String id,
  String description, {
  required Future<void> Function(FeatureTest test) run,
  FeatureVariant variant = const FeatureVariant('mobile-light'),
  String kind = 'feature',
  bool loadFonts = true,
  Timeout timeout = const Timeout(Duration(seconds: 45)),
}) {
  if (!RegExp(r'^[a-z0-9][a-z0-9._-]*$').hasMatch(id)) {
    throw ArgumentError.value(id, 'id', 'Use lowercase letters, numbers, dots, _ and -');
  }
  testWidgets('[$id] $description', (tester) async {
    final test = FeatureTest._(tester, id, description, variant, kind);
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = variant.size;
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);
    final stopwatch = Stopwatch()..start();
    try {
      if (loadFonts) await test.step('Load bundled fonts', () => loadBundledTestFonts(tester));
      await run(test);
      test.checkFlutterErrors();
      test._record['status'] = 'passed';
    } catch (error, stack) {
      test._record.addAll({'status': 'failed', 'error': '$error', 'stack': '$stack'});
      try {
        await test.checkpoint('failure');
      } catch (captureError) {
        test._record['captureError'] = '$captureError';
      }
      rethrow;
    } finally {
      test._record['durationMs'] = stopwatch.elapsedMilliseconds;
      test._writeRecord();
      // Unmount before product cleanup callbacks dispose databases and blocs.
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump();
      for (final cleanup in test._cleanups.reversed) {
        await cleanup();
      }
    }
  }, timeout: timeout);
}

class FeatureTest {
  FeatureTest._(this.tester, this.id, String description, this.variant, String kind)
    : _record = {
        'id': id,
        'name': '[$id] $description',
        'description': description,
        'kind': kind,
        'variant': variant.name,
        'viewport': '${variant.size.width.toInt()} × ${variant.size.height.toInt()}',
        'locale': variant.locale.toLanguageTag(),
        'brightness': variant.brightness.name,
        'textScale': variant.textScale,
        'status': 'running',
        'steps': <Map<String, Object?>>[],
        'checkpoints': <Map<String, Object?>>[],
        'frames': <Map<String, Object?>>[],
      };

  final _cleanups = <Future<void> Function()>[];

  /// Dispose resources after unmount, while still inside the widget test clock.
  void onCleanup(Future<void> Function() cleanup) => _cleanups.add(cleanup);

  final WidgetTester tester;
  final String id;
  final FeatureVariant variant;
  final _boundary = GlobalKey();
  final Map<String, Object?> _record;
  static const _recordSteps = bool.fromEnvironment('HIPPO_TEST_RECORD_STEPS');
  static const _reportPath = String.fromEnvironment('HIPPO_TEST_REPORT');

  List<Map<String, Object?>> get _steps => _record['steps']! as List<Map<String, Object?>>;
  List<Map<String, Object?>> get _checkpoints =>
      _record['checkpoints']! as List<Map<String, Object?>>;

  /// Wrap the actual product composition, supplied by the product adapter.
  Future<void> mount(Widget app) async {
    await tester.pumpWidget(
      RepaintBoundary(
        key: _boundary,
        child: MediaQuery(
          data: MediaQueryData(
            size: variant.size,
            platformBrightness: variant.brightness,
            textScaler: TextScaler.linear(variant.textScale),
          ),
          child: app,
        ),
      ),
    );
    checkFlutterErrors();
  }

  Future<T> step<T>(String name, Future<T> Function() action) async {
    final entry = <String, Object?>{'name': name, 'status': 'running'};
    _steps.add(entry);
    _writeRecord();
    final stopwatch = Stopwatch()..start();
    try {
      final result = await action();
      checkFlutterErrors();
      entry['status'] = 'passed';
      return result;
    } catch (error) {
      entry.addAll({'status': 'failed', 'error': '$error'});
      rethrow;
    } finally {
      entry['durationMs'] = stopwatch.elapsedMilliseconds;
      if (_recordSteps && _reportPath.isNotEmpty && _boundary.currentContext != null) {
        // Capture evidence without masking the original action failure.
        try {
          final frames = _record['frames']! as List<Map<String, Object?>>;
          final frame = <String, Object?>{
            'name': name,
            'stepIndex': _steps.indexOf(entry),
            'status': entry['status'],
          };
          _saveImage(frame, 'actual', 'step-${frames.length}', await _capture());
          frames.add(frame);
        } catch (error) {
          entry['captureError'] = '$error';
        }
      }
      _writeRecord();
    }
  }

  /// A bounded condition wait that also works with continuously animated UIs.
  Future<void> waitFor(
    Finder finder, {
    Duration timeout = const Duration(seconds: 5),
    Duration interval = const Duration(milliseconds: 50),
  }) async {
    if (timeout <= Duration.zero || interval <= Duration.zero) {
      throw ArgumentError('Wait timeout and interval must be positive');
    }
    var elapsed = Duration.zero;
    while (finder.evaluate().isEmpty) {
      if (elapsed >= timeout) {
        throw TestFailure('Timed out after $timeout waiting for $finder');
      }
      await tester.pump(interval);
      elapsed += interval;
      checkFlutterErrors();
    }
  }

  /// Await work whose completion needs the widget clock (e.g. stream shutdown).
  Future<T> complete<T>(
    Future<T> operation, {
    Duration timeout = const Duration(seconds: 5),
  }) async {
    var done = false;
    Object? failure;
    StackTrace? stack;
    T? value;
    operation.then(
      (result) {
        value = result;
        done = true;
      },
      onError: (Object error, StackTrace trace) {
        failure = error;
        stack = trace;
        done = true;
      },
    );
    var elapsed = Duration.zero;
    const interval = Duration(milliseconds: 50);
    while (!done) {
      if (elapsed >= timeout) throw TestFailure('Operation did not complete within $timeout');
      await tester.pump(interval);
      elapsed += interval;
    }
    if (failure != null) Error.throwWithStackTrace(failure!, stack!);
    return value as T;
  }

  /// Use for known finite transitions; never silently retry a failed action.
  Future<void> settle() async {
    await tester.pumpAndSettle(
      const Duration(milliseconds: 50),
      EnginePhase.sendSemanticsUpdate,
      const Duration(seconds: 5),
    );
    checkFlutterErrors();
  }

  void checkFlutterErrors() {
    final error = tester.takeException();
    if (error != null) throw TestFailure('Flutter framework error: $error');
  }

  /// A named screenshot, optionally checked by Flutter's configured comparator.
  /// [golden] is relative to the calling test file, as with matchesGoldenFile.
  Future<void> checkpoint(String name, {String? golden}) async {
    final number = _checkpoints.length;
    final entry = <String, Object?>{'name': name, 'status': 'captured'};
    _checkpoints.add(entry);
    _writeRecord();
    final bytes = await _capture();
    _saveImage(entry, 'actual', '$number-actual', bytes);
    if (golden != null) {
      entry['golden'] = golden;
      // Copy review artifacts before updating; preserve the previous baseline.
      final comparator = goldenFileComparator;
      if (comparator is LocalFileComparator) {
        final file = File.fromUri(comparator.basedir.resolve(golden));
        if (file.existsSync()) {
          final expected = file.readAsBytesSync();
          _saveImage(entry, 'expected', '$number-expected', expected);
          await tester.runAsync(() async {
            final comparison = await GoldenFileComparator.compareLists(bytes, expected);
            try {
              entry['diffPercent'] = comparison.diffPercent;
              for (final key in ['isolatedDiff', 'maskedDiff']) {
                final image = comparison.diffs?[key];
                if (image == null) continue;
                final data = await image.toByteData(format: ui.ImageByteFormat.png);
                _saveImage(entry, key, '$number-$key', data!.buffer.asUint8List());
              }
            } finally {
              comparison.dispose();
            }
          });
        }
      }
      try {
        // Byte-based golden matching performs file I/O directly. Run it outside
        // the widget test's fake clock, retaining the original assertion error.
        Object? failure;
        StackTrace? failureStack;
        await tester.runAsync(() async {
          try {
            await expectLater(bytes, matchesGoldenFile(golden));
          } catch (error, stack) {
            failure = error;
            failureStack = stack;
          }
        });
        if (failure != null) Error.throwWithStackTrace(failure!, failureStack!);
        entry['status'] = autoUpdateGoldenFiles ? 'updated' : 'passed';
      } catch (error) {
        entry.addAll({'status': 'failed', 'error': '$error'});
        rethrow;
      } finally {
        _writeRecord();
      }
    }
  }

  /// Attach a recording produced by a device/browser runner. The video is copied
  /// into the portable report; this does not itself record the screen.
  Future<void> attachVideo(File recording) async {
    final extension = recording.path.split('.').last.toLowerCase();
    if (!['mp4', 'webm'].contains(extension)) throw ArgumentError('Use an MP4 or WebM recording');
    if (_reportPath.isEmpty) return;
    final relative = '$id/recording.$extension';
    final target = File('$_reportPath/$relative');
    target.parent.createSync(recursive: true);
    await tester.runAsync(() => recording.copy(target.path));
    _record['video'] = relative;
    _writeRecord();
  }

  Future<Uint8List> _capture() async {
    final bytes = await tester.runAsync(() async {
      final boundary = _boundary.currentContext?.findRenderObject() as RenderRepaintBoundary?;
      if (boundary == null) throw StateError('Call mount before checkpoint');
      final image = await boundary.toImage(pixelRatio: 1);
      try {
        final data = await image.toByteData(format: ui.ImageByteFormat.png);
        return data!.buffer.asUint8List();
      } finally {
        image.dispose();
      }
    });
    if (bytes == null) throw StateError('Screenshot capture failed');
    return bytes;
  }

  void _saveImage(Map<String, Object?> entry, String key, String suffix, Uint8List bytes) {
    if (_reportPath.isEmpty) return;
    final relative = '$id/$suffix.png';
    final file = File('$_reportPath/$relative');
    file.parent.createSync(recursive: true);
    file.writeAsBytesSync(bytes);
    entry[key] = relative;
  }

  void _writeRecord() {
    if (_reportPath.isEmpty) return;
    final file = File('$_reportPath/$id.json');
    file.parent.createSync(recursive: true);
    file.writeAsStringSync(const JsonEncoder.withIndent('  ').convert(_record));
  }
}

/// Real font rendering instead of Flutter test's square fallback glyphs.
Future<void> loadBundledTestFonts(WidgetTester tester) async {
  await tester.runAsync(() async {
    // Material's implicit Roboto is not in an app's FontManifest. The pinned
    // Flutter SDK ships it; load that exact font instead of square test glyphs.
    if (tester.binding is AutomatedTestWidgetsFlutterBinding) {
      final root = Platform.environment['FLUTTER_ROOT'];
      if (root == null) throw StateError('FLUTTER_ROOT is required to load SDK fonts');
      final loader = FontLoader('Roboto');
      for (final style in [
        'Regular',
        'Medium',
        'Bold',
        'Italic',
        'BoldItalic',
        'Light',
        'Thin',
        'Black',
      ]) {
        final bytes = File('$root/bin/cache/artifacts/material_fonts/Roboto-$style.ttf')
            .readAsBytesSync();
        loader.addFont(Future.value(ByteData.sublistView(bytes)));
      }
      await loader.load();
    }
    final manifest = jsonDecode(await rootBundle.loadString('FontManifest.json')) as List;
    for (final entry in manifest.cast<Map<String, dynamic>>()) {
      final loader = FontLoader(entry['family'] as String);
      for (final font in (entry['fonts'] as List).cast<Map<String, dynamic>>()) {
        loader.addFont(rootBundle.load(Uri.decodeFull(font['asset'] as String)));
      }
      await loader.load();
    }
  });
}
