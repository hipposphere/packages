import 'dart:async';
import 'dart:js_interop';
import 'dart:js_interop_unsafe';
import 'dart:typed_data';

import 'package:web/web.dart' as web;

import 'hippo_zstandard.dart';

const _defaultAssetBaseUrl = 'assets/packages/hippo_zstandard/web/';
final _clients = <String, _WorkerClient>{};

Future<Uint8List> compress(
  Uint8List input, {
  required int level,
  required String? webAssetBaseUrl,
}) => _client(webAssetBaseUrl).execute(input, operation: 'compress', value: level);

Future<Uint8List> decompress(
  Uint8List input, {
  required int maxOutputBytes,
  required String? webAssetBaseUrl,
}) => _client(webAssetBaseUrl).execute(input, operation: 'decompress', value: maxOutputBytes);

_WorkerClient _client(String? baseUrl) {
  final resolvedBaseUrl = _resolveBaseUrl(baseUrl ?? _defaultAssetBaseUrl);
  return _clients.putIfAbsent(resolvedBaseUrl, () => _WorkerClient(resolvedBaseUrl));
}

String _resolveBaseUrl(String baseUrl) {
  final withSlash = baseUrl.endsWith('/') ? baseUrl : '$baseUrl/';
  return Uri.parse(web.document.baseURI).resolve(withSlash).toString();
}

final class _WorkerClient {
  _WorkerClient(this.assetBaseUrl);

  final String assetBaseUrl;
  final _pending = <int, Completer<Uint8List>>{};
  web.Worker? _worker;
  Future<void>? _initialization;
  int _nextRequestId = 0;

  Future<Uint8List> execute(
    Uint8List input, {
    required String operation,
    required int value,
  }) async {
    await (_initialization ??= _initialize());
    final worker = _worker;
    if (worker == null) {
      throw const HippoZstandardException(HippoZstandardError.internal);
    }

    final id = ++_nextRequestId;
    final completer = Completer<Uint8List>();
    _pending[id] = completer;

    final transferredData = Uint8List.fromList(input);
    final transferredBytes = transferredData.toJS;
    final request = JSObject()
      ..setProperty('id'.toJS, id.toJS)
      ..setProperty('operation'.toJS, operation.toJS)
      ..setProperty('bytes'.toJS, transferredBytes)
      ..setProperty('value'.toJS, value.toJS);
    worker.postMessage(request, <JSAny>[transferredData.buffer.toJS].toJS);
    return completer.future;
  }

  Future<void> _initialize() async {
    final ready = Completer<void>();
    final worker = web.Worker('${assetBaseUrl}hippo_zstandard_worker.js'.toJS);
    _worker = worker;

    worker.onmessage = ((web.MessageEvent event) {
      final message = event.data as JSObject;
      final type = message.getProperty<JSAny?>('type'.toJS)?.dartify();
      if (type == 'ready') {
        if (!ready.isCompleted) {
          ready.complete();
        }
        return;
      }

      final id = message.getProperty<JSAny?>('id'.toJS)?.dartify() as int?;
      if (id == null) {
        return;
      }
      final completer = _pending.remove(id);
      if (completer == null) {
        return;
      }

      final error = message.getProperty<JSAny?>('error'.toJS)?.dartify() as int? ?? 0;
      if (error != 0) {
        final details = message.getProperty<JSAny?>('details'.toJS)?.dartify() as String?;
        completer.completeError(HippoZstandardException(_errorFromCode(error), details: details));
        return;
      }

      final bytes = message.getProperty<JSAny?>('bytes'.toJS);
      if (bytes != null) {
        completer.complete(Uint8List.fromList((bytes as JSUint8Array).toDart));
      } else {
        completer.completeError(
          const HippoZstandardException(
            HippoZstandardError.internal,
            details: 'The web worker returned no output bytes.',
          ),
        );
      }
    }).toJS;
    worker.onerror = ((web.Event event) {
      final errorEvent = event as JSObject;
      final message = errorEvent.getProperty<JSAny?>('message'.toJS)?.dartify() as String?;
      final filename = errorEvent.getProperty<JSAny?>('filename'.toJS)?.dartify() as String?;
      final line = errorEvent.getProperty<JSAny?>('lineno'.toJS)?.dartify();
      final column = errorEvent.getProperty<JSAny?>('colno'.toJS)?.dartify();
      final details = [
        message ?? 'Web worker error.',
        if (filename != null) '$filename:$line:$column',
      ].join(' ');
      final error = HippoZstandardException(HippoZstandardError.internal, details: details);
      if (!ready.isCompleted) {
        ready.completeError(error);
      }
      for (final completer in _pending.values) {
        completer.completeError(error);
      }
      _pending.clear();
      worker.terminate();
      _worker = null;
      _initialization = null;
    }).toJS;

    worker.postMessage(
      <String, Object?>{
        'operation': 'initialize',
        'wasmUrl': '${assetBaseUrl}hippo_zstandard.wasm',
      }.jsify(),
    );
    return ready.future;
  }
}

HippoZstandardError _errorFromCode(int code) => switch (code) {
  1 => HippoZstandardError.invalidData,
  2 => HippoZstandardError.outputLimitExceeded,
  4 => HippoZstandardError.invalidArgument,
  _ => HippoZstandardError.internal,
};
