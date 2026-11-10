/// A label of a series, a stream or a span attribute.
final class WireLabel {
  const WireLabel(this.name, this.value);

  final String name;
  final String value;

  @override
  bool operator ==(Object other) =>
      other is WireLabel && other.name == name && other.value == value;

  @override
  int get hashCode => Object.hash(name, value);

  @override
  String toString() => '$name="$value"';
}

/// The type of a [WireField]'s values.
enum WireFieldType {
  /// Epoch milliseconds in [WireField.numbers].
  time,

  /// Numbers in [WireField.numbers]; null marks a missing value.
  number,

  /// Text in [WireField.strings].
  string,
}

/// One column of a [WireFrame].
final class WireField {
  const WireField({
    required this.name,
    required this.type,
    this.labels = const [],
    this.unit,
    this.displayName,
    this.numbers,
    this.strings,
  });

  final String name;
  final WireFieldType type;
  final List<WireLabel> labels;
  final String? unit;
  final String? displayName;

  /// Values of `time` and `number` fields.
  final List<num?>? numbers;

  /// Values of `string` fields.
  final List<String?>? strings;

  int get length => numbers?.length ?? strings?.length ?? 0;
}

/// What a [WireFrame] holds.
enum WireFrameKind { timeSeries, table, logs }

/// Columns of equal length: a wide time series (one `time` field and one
/// `number` field per series), a table, or the lines of one log stream.
final class WireFrame {
  const WireFrame({required this.kind, required this.fields, this.name, this.labels = const []});

  final WireFrameKind kind;
  final List<WireField> fields;
  final String? name;

  /// Shared labels, such as a log stream's.
  final List<WireLabel> labels;
}

/// The frames of one query, and whether limits cut the result.
final class WireResult {
  const WireResult(this.frames, {this.limited = false, this.notices = const []});

  final List<WireFrame> frames;
  final bool limited;
  final List<String> notices;
}

/// One span of a trace.
final class WireSpan {
  const WireSpan({
    required this.spanId,
    required this.name,
    required this.service,
    required this.start,
    required this.durationMs,
    required this.status,
    required this.attributes,
    this.parentSpanId,
    this.statusMessage,
  });

  /// 16 lowercase hex digits.
  final String spanId;
  final String? parentSpanId;
  final String name;
  final String service;
  final DateTime start;
  final double durationMs;

  /// `unset`, `ok` or `error`.
  final String status;
  final String? statusMessage;

  /// Span attributes, then resource attributes prefixed `resource.`.
  final List<WireLabel> attributes;
}
