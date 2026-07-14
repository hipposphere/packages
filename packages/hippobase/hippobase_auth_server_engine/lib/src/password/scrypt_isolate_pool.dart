part of '../password.dart';

final class _ScryptIsolatePool {
  _ScryptIsolatePool(this.size);

  final int size;
  final Queue<_ScryptJob> _pending = Queue<_ScryptJob>();
  final List<_ScryptWorker> _workers = <_ScryptWorker>[];
  final List<_ScryptWorker> _idle = <_ScryptWorker>[];
  Future<void>? _started;
  bool _closed = false;

  Future<String> run(Map<String, String> input) async {
    if (_closed) throw StateError('Password service is closed.');
    await (_started ??= _start());
    if (_closed) throw StateError('Password service is closed.');
    final completer = Completer<String>();
    _pending.add(_ScryptJob(input, completer));
    _drain();
    return completer.future;
  }

  Future<void> _start() async {
    for (var index = 0; index < size; index++) {
      final ready = ReceivePort();
      final exited = ReceivePort();
      await Isolate.spawn<SendPort>(
        _scryptWorkerMain,
        ready.sendPort,
        onExit: exited.sendPort,
        debugName: 'hippobase-auth-scrypt-$index',
      );
      final sendPort = await ready.first as SendPort;
      ready.close();
      final worker = _ScryptWorker(sendPort, exited.first.then((_) {}));
      _workers.add(worker);
      _idle.add(worker);
    }
  }

  void _drain() {
    while (!_closed && _pending.isNotEmpty && _idle.isNotEmpty) {
      final worker = _idle.removeLast();
      final job = _pending.removeFirst();
      final response = ReceivePort();
      response.first.then((message) {
        response.close();
        if (message case <String, Object?>{'result': final String result}) {
          job.completer.complete(result);
        } else {
          final error = message is Map ? message['error'] : message;
          job.completer.completeError(StateError('Scrypt worker failed: $error'));
        }
        if (!_closed) {
          _idle.add(worker);
          _drain();
        }
      });
      worker.sendPort.send(<Object?>[response.sendPort, job.input]);
    }
  }

  Future<void> close() async {
    if (_closed) return;
    _closed = true;
    while (_pending.isNotEmpty) {
      _pending.removeFirst().completer.completeError(StateError('Password service is closed.'));
    }
    final started = _started;
    if (started != null) await started;
    for (final worker in _workers) {
      worker.sendPort.send(null);
    }
    await Future.wait<void>(_workers.map((worker) => worker.exited));
    _idle.clear();
    _workers.clear();
  }
}

final class _ScryptJob {
  const _ScryptJob(this.input, this.completer);

  final Map<String, String> input;
  final Completer<String> completer;
}

final class _ScryptWorker {
  const _ScryptWorker(this.sendPort, this.exited);

  final SendPort sendPort;
  final Future<void> exited;
}

void _scryptWorkerMain(SendPort ready) {
  final requests = ReceivePort();
  ready.send(requests.sendPort);
  requests.listen((message) {
    if (message == null) {
      requests.close();
      return;
    }
    final values = message! as List<Object?>;
    final reply = values[0]! as SendPort;
    final input = (values[1]! as Map).cast<String, String>();
    try {
      reply.send(<String, Object?>{'result': _deriveScrypt(input)});
    } catch (error, stackTrace) {
      reply.send(<String, Object?>{'error': '$error\n$stackTrace'});
    }
  });
}

String _deriveScrypt(Map<String, String> input) {
  final salt = _decodeHex(input['salt']!)!;
  final normalized = unorm.nfkc(input['password']!);
  final password = Uint8List.fromList(utf8.encode(normalized));
  final output = Uint8List(HippobaseAuthScryptPasswordService.outputLength);
  final derivator = Scrypt()
    ..init(
      ScryptParameters(
        HippobaseAuthScryptPasswordService.cost,
        HippobaseAuthScryptPasswordService.blockSize,
        HippobaseAuthScryptPasswordService.parallelization,
        HippobaseAuthScryptPasswordService.outputLength,
        Uint8List.fromList(salt),
      ),
    );
  derivator.deriveKey(password, 0, output, 0);
  return _hex(output);
}

String _hex(List<int> bytes) =>
    bytes.map((value) => value.toRadixString(16).padLeft(2, '0')).join();

Uint8List? _decodeHex(String value) {
  if (value.length.isOdd || !RegExp(r'^[0-9a-fA-F]*$').hasMatch(value)) return null;
  return Uint8List.fromList(<int>[
    for (var index = 0; index < value.length; index += 2)
      int.parse(value.substring(index, index + 2), radix: 16),
  ]);
}

bool _constantTimeEquals(List<int> left, List<int> right) {
  var difference = left.length ^ right.length;
  final length = left.length < right.length ? left.length : right.length;
  for (var index = 0; index < length; index++) {
    difference |= left[index] ^ right[index];
  }
  return difference == 0;
}
