import 'frames.dart';

/// The `data` object of a Prometheus-style `{status, data}` envelope.
Map<Object?, Object?> envelopeData(Object? json) {
  if (json case {'data': final Map<Object?, Object?> data}) {
    return data;
  }
  throw const FormatException('Missing data');
}

/// Prometheus-style `warnings` and `infos` of an envelope, as notices.
List<String> envelopeNotices(Object? json) => [
  if (json is Map)
    for (final key in ['warnings', 'infos'])
      for (final notice in (json[key] as List<Object?>? ?? const [])) '$notice',
];

/// The strings of a `{data: [...]}` label or tag lookup.
List<String> envelopeStrings(Object? json) {
  if (json case {'data': final List<Object?> data}) return [for (final value in data) '$value'];
  throw const FormatException('Missing data');
}

List<WireLabel> sortedLabels(Map<Object?, Object?> values) => [
  for (final key in values.keys.map((k) => '$k').toList()..sort()) WireLabel(key, '${values[key]}'),
];

/// `name{a="b"}` like Prometheus, or `Value` for a series without labels.
String seriesName(List<WireLabel> labels) {
  final name = labels.where((l) => l.name == '__name__').firstOrNull?.value ?? '';
  final rest = labels.where((l) => l.name != '__name__').map((l) => '${l.name}="${l.value}"');
  if (rest.isEmpty) return name.isEmpty ? 'Value' : name;
  return '$name{${rest.join(', ')}}';
}

final _legendPattern = RegExp(r'\{\{\s*([^}\s]+)\s*\}\}');

/// Grafana-style legend: `{{label}}` inserts that label's value.
String applyLegend(String legend, List<WireLabel> labels) => legend.replaceAllMapped(
  _legendPattern,
  (m) => labels.where((l) => l.name == m[1]).firstOrNull?.value ?? '',
);

int _millis(Object? seconds) => switch (seconds) {
  final num value => (value * 1000).round(),
  final String value => (double.parse(value) * 1000).round(),
  _ => throw const FormatException('Invalid sample timestamp'),
};

num? _sample(Object? value) {
  final parsed = value is num ? value.toDouble() : double.tryParse('$value');
  return parsed == null || !parsed.isFinite ? null : parsed;
}

/// Normalizes a Prometheus (or Loki metric) `data` object into one wide
/// `timeSeries` frame: a `time` field over the union of all timestamps and one
/// `number` field per series, null where that series has no sample. At most
/// [maxSeries] series are kept. Non-finite values become null.
WireResult normalizeMetricData(
  Map<Object?, Object?> data, {
  required DateTime evaluatedAt,
  required int maxSeries,
  String? name,
  String? legend,
  String? unit,
}) {
  final resultType = data['resultType'];
  final result = data['result'];
  if (resultType == 'scalar' || resultType == 'string') {
    final sample = result as List<Object?>;
    final time = _millis(sample[0]);
    return WireResult([
      WireFrame(
        name: name,
        kind: WireFrameKind.timeSeries,
        fields: [
          WireField(name: 'time', type: WireFieldType.time, numbers: [time]),
          if (resultType == 'scalar')
            WireField(
              name: 'Value',
              type: WireFieldType.number,
              unit: unit,
              displayName: legend,
              numbers: [_sample(sample[1])],
            )
          else
            WireField(
              name: 'Value',
              type: WireFieldType.string,
              displayName: legend,
              strings: ['${sample[1]}'],
            ),
        ],
      ),
    ]);
  }
  if (resultType != 'matrix' && resultType != 'vector') {
    throw FormatException('Unexpected result type $resultType');
  }
  final entries = (result as List<Object?>).cast<Map<Object?, Object?>>();
  final kept = entries.take(maxSeries).toList();
  final instant = resultType == 'vector';
  final evaluated = evaluatedAt.millisecondsSinceEpoch;
  final times = <int>{if (instant && kept.isNotEmpty) evaluated};
  final samples = <Map<int, num?>>[];
  var histograms = false;
  for (final entry in kept) {
    final values = <int, num?>{};
    if (instant) {
      if (entry['value'] case final List<Object?> sample) values[evaluated] = _sample(sample[1]);
      histograms |= entry.containsKey('histogram');
    } else {
      for (final sample in (entry['values'] as List<Object?>? ?? const []).cast<List<Object?>>()) {
        final time = _millis(sample[0]);
        values[time] = _sample(sample[1]);
        times.add(time);
      }
      histograms |= entry.containsKey('histograms');
    }
    samples.add(values);
  }
  final sorted = times.toList()..sort();
  final seriesLabels = [
    for (final entry in kept) sortedLabels((entry['metric'] as Map<Object?, Object?>?) ?? const {}),
  ];
  final fields = <WireField>[
    WireField(name: 'time', type: WireFieldType.time, numbers: sorted),
    for (final (index, labels) in seriesLabels.indexed)
      WireField(
        name: seriesName(labels),
        type: WireFieldType.number,
        labels: labels,
        unit: unit,
        displayName: legend == null ? null : applyLegend(legend, labels),
        numbers: [for (final time in sorted) samples[index][time]],
      ),
  ];
  final limited = entries.length > kept.length;
  return WireResult(
    [WireFrame(name: name, kind: WireFrameKind.timeSeries, fields: fields)],
    limited: limited,
    notices: [
      if (limited) 'Showing the first ${kept.length} of ${entries.length} series',
      if (histograms) 'Native histogram samples are not shown; use histogram_quantile()',
    ],
  );
}
