import 'dart:convert';

import 'package:file_selector/file_selector.dart';
import 'package:flutter/services.dart';

Future<String?> exportDiagnosticsNdjsonFile({
  required String appName,
  required String ndjson,
}) async {
  final fileName = _exportFileName(appName);
  try {
    final location = await getSaveLocation(
      suggestedName: fileName,
      acceptedTypeGroups: const <XTypeGroup>[
        XTypeGroup(label: 'NDJSON logs', extensions: <String>['ndjson']),
      ],
    );
    if (location == null) {
      return null;
    }
    await XFile.fromData(
      Uint8List.fromList(utf8.encode(ndjson)),
      mimeType: 'application/x-ndjson',
      name: fileName,
    ).saveTo(location.path);
    return location.path;
  } on UnimplementedError {
    return null;
  } on UnsupportedError {
    return null;
  } on MissingPluginException {
    return null;
  } on PlatformException {
    return null;
  } catch (_) {
    return null;
  }
}

String _exportFileName(String appName) {
  final safeAppName = appName.toLowerCase().replaceAll(RegExp(r'[^a-z0-9._-]+'), '_');
  final timestamp = DateTime.now().toUtc().toIso8601String().replaceAll(RegExp(r'[:.]'), '-');
  return '$safeAppName-logs-$timestamp.ndjson';
}
