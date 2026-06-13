import 'dart:async';

import 'console.dart';

final class HippoSpinner {
  HippoSpinner({required this.console, required this.label, required this.enabled});

  final HippoConsole console;
  final String label;
  final bool enabled;
  Timer? _timer;
  var _frame = 0;

  static const _frames = ['-', r'\', '|', '/'];

  void start() {
    if (!enabled) {
      console.run(label);
      return;
    }
    console.write('\r${_frames.first} $label');
    _timer = Timer.periodic(const Duration(milliseconds: 100), (_) {
      _frame = (_frame + 1) % _frames.length;
      console.write('\r${_frames[_frame]} $label');
    });
  }

  void finish([String? message]) {
    _timer?.cancel();
    _timer = null;
    if (enabled) {
      console.write('\r');
      console.clearLine();
    }
    if (message != null && message.isNotEmpty) {
      console.ok(message);
    }
  }

  Future<T> during<T>(Future<T> Function() operation) async {
    start();
    try {
      final result = await operation();
      finish();
      return result;
    } on Object {
      finish();
      rethrow;
    }
  }
}
