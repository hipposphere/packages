import 'dart:async';
import 'dart:io';

import 'package:path/path.dart' as path;

import 'diagnostic_log_entry.dart';
import 'diagnostic_log_query.dart';
import 'diagnostics_store.dart';
import 'ndjson_diagnostics_codec.dart';

final class FileDiagnosticsStore implements DiagnosticsStore {
  FileDiagnosticsStore({
    required this.directoryPath,
    required this.filePrefix,
    this.maxBytesPerFile = 5 * 1024 * 1024,
    this.maxFiles = 8,
  });

  final String directoryPath;
  final String filePrefix;
  final int maxBytesPerFile;
  final int maxFiles;
  final StreamController<DiagnosticLogEntry> _controller =
      StreamController<DiagnosticLogEntry>.broadcast();

  Future<void> _pending = Future<void>.value();

  @override
  Stream<DiagnosticLogEntry> get entries => _controller.stream;

  Directory get _directory => Directory(directoryPath);

  File get _currentFile => File(path.join(directoryPath, '$filePrefix.current.ndjson'));

  @override
  Future<void> append(DiagnosticLogEntry entry) {
    _pending = _pending.then((_) => _append(entry));
    return _pending;
  }

  Future<void> _append(DiagnosticLogEntry entry) async {
    await _directory.create(recursive: true);
    if (await _currentFile.exists() && await _currentFile.length() >= maxBytesPerFile) {
      await _rotate();
    }
    await _currentFile.writeAsString(
      '${NdjsonDiagnosticsCodec.encodeEntry(entry)}\n',
      mode: FileMode.append,
      flush: false,
    );
    _controller.add(entry);
  }

  Future<void> _rotate() async {
    final current = _currentFile;
    if (!await current.exists()) {
      return;
    }
    final timestamp = DateTime.now().toUtc().toIso8601String().replaceAll(RegExp(r'[:.]'), '-');
    final rotated = File(path.join(directoryPath, '$filePrefix.$timestamp.ndjson'));
    await current.rename(rotated.path);
    await _trimOldFiles();
  }

  Future<void> _trimOldFiles() async {
    final files = await _logFiles();
    final rotatedFiles = files.where((file) => file.path != _currentFile.path).toList();
    if (rotatedFiles.length <= maxFiles - 1) {
      return;
    }
    final deleteCount = rotatedFiles.length - (maxFiles - 1);
    for (final file in rotatedFiles.take(deleteCount)) {
      if (await file.exists()) {
        await file.delete();
      }
    }
  }

  @override
  Future<void> clear() async {
    await _pending;
    final files = await _logFiles();
    for (final file in files) {
      if (await file.exists()) {
        await file.delete();
      }
    }
  }

  @override
  Future<List<DiagnosticLogEntry>> query([
    DiagnosticLogQuery query = const DiagnosticLogQuery(),
  ]) async {
    await _pending;
    final entries = <DiagnosticLogEntry>[];
    for (final file in await _logFiles()) {
      if (!await file.exists()) {
        continue;
      }
      final lines = await file.readAsLines();
      for (final line in lines) {
        final entry = NdjsonDiagnosticsCodec.tryDecodeEntry(line);
        if (entry != null) {
          entries.add(entry);
        }
      }
    }
    return query.apply(entries);
  }

  Future<List<File>> _logFiles() async {
    if (!await _directory.exists()) {
      return <File>[];
    }
    final files = await _directory
        .list()
        .where((entity) {
          final name = path.basename(entity.path);
          return entity is File && name.startsWith('$filePrefix.') && name.endsWith('.ndjson');
        })
        .cast<File>()
        .toList();
    files.sort((a, b) => a.path.compareTo(b.path));
    return files;
  }

  Future<void> close() async {
    await _controller.close();
  }
}
