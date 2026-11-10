import 'frames.dart';
import 'metrics.dart';

/// Log lines longer than this are truncated.
const maxLogLineLength = 16 * 1024;

/// Normalizes Loki `streams` into one `logs` frame per stream (the stream's
/// labels are the frame labels), newest first. [limit] is the line limit that
/// was sent to Loki; reaching it marks the result limited.
WireResult normalizeLokiStreams(List<Object?> streams, {required int limit}) {
  var total = 0;
  var truncated = 0;
  final frames = <(int, WireFrame)>[];
  for (final stream in streams.cast<Map<Object?, Object?>>()) {
    final entries = <(int, String)>[
      for (final value in (stream['values'] as List<Object?>? ?? const []).cast<List<Object?>>())
        (int.parse('${value[0]}'), '${value[1]}'),
    ]..sort((a, b) => b.$1.compareTo(a.$1));
    if (entries.isEmpty) continue;
    total += entries.length;
    truncated += entries.where((e) => e.$2.length > maxLogLineLength).length;
    final labels = sortedLabels((stream['stream'] as Map<Object?, Object?>?) ?? const {});
    frames.add((
      entries.first.$1,
      WireFrame(
        name: '{${labels.map((l) => '${l.name}="${l.value}"').join(', ')}}',
        kind: WireFrameKind.logs,
        labels: labels,
        fields: [
          WireField(
            name: 'time',
            type: WireFieldType.time,
            numbers: [for (final entry in entries) entry.$1 ~/ 1000000],
          ),
          WireField(
            name: 'line',
            type: WireFieldType.string,
            strings: [for (final (_, line) in entries) _truncate(line)],
          ),
        ],
      ),
    ));
  }
  frames.sort((a, b) => b.$1.compareTo(a.$1));
  final limited = total >= limit;
  return WireResult(
    [for (final (_, frame) in frames) frame],
    limited: limited,
    notices: [
      if (limited) 'Showing the newest $limit lines',
      if (truncated > 0) '$truncated lines longer than 16 KiB were truncated',
    ],
  );
}

String _truncate(String line) =>
    line.length > maxLogLineLength ? '${line.substring(0, maxLogLineLength)}…' : line;
