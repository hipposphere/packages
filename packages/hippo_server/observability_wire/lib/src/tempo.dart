import 'dart:convert';

import 'frames.dart';

final _hex = RegExp(r'^[0-9a-fA-F]+$');

/// Lowercase hex for a hex or base64 (protobuf JSON) ID; null when invalid.
/// Trace IDs are left-padded to 32 digits because Tempo trims leading zeros.
String? normalizeTraceId(String value, {int width = 32}) {
  final trimmed = value.trim();
  if (trimmed.isEmpty) return null;
  if (trimmed.length <= width && _hex.hasMatch(trimmed)) {
    return trimmed.toLowerCase().padLeft(width, '0');
  }
  try {
    final bytes = base64.decode(trimmed);
    if (bytes.isEmpty || bytes.length > width ~/ 2) return null;
    return bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join().padLeft(width, '0');
  } on FormatException {
    return null;
  }
}

/// Normalizes a Tempo search response into one `table` frame of traces with
/// the fields `trace_id`, `service`, `name`, `start` and `duration` (ms).
WireResult normalizeTempoSearch(Map<Object?, Object?> json, {required int limit}) {
  final traces = (json['traces'] as List<Object?>? ?? const []).cast<Map<Object?, Object?>>();
  final limited = traces.length >= limit;
  String? text(Object? value) => value == null ? null : '$value';
  return WireResult(
    [
      WireFrame(
        name: 'traces',
        kind: WireFrameKind.table,
        fields: [
          WireField(
            name: 'trace_id',
            type: WireFieldType.string,
            strings: [for (final t in traces) normalizeTraceId('${t['traceID'] ?? ''}')],
          ),
          WireField(
            name: 'service',
            type: WireFieldType.string,
            strings: [for (final t in traces) text(t['rootServiceName'])],
          ),
          WireField(
            name: 'name',
            type: WireFieldType.string,
            strings: [for (final t in traces) text(t['rootTraceName'])],
          ),
          WireField(
            name: 'start',
            type: WireFieldType.time,
            numbers: [
              for (final t in traces)
                switch (int.tryParse('${t['startTimeUnixNano']}')) {
                  final nanos? => nanos ~/ 1000000,
                  null => null,
                },
            ],
          ),
          WireField(
            name: 'duration',
            type: WireFieldType.number,
            unit: 'ms',
            // Tempo omits durationMs below one millisecond.
            numbers: [for (final t in traces) (t['durationMs'] as num?) ?? 0],
          ),
        ],
      ),
    ],
    limited: limited,
    notices: [if (limited) 'Showing the first $limit traces'],
  );
}

/// Span IDs are 8 bytes: 16 hex digits.
String? _spanId(Object? value) =>
    value == null || '$value'.isEmpty ? null : normalizeTraceId('$value', width: 16);

String _anyValue(Object? value) => switch (value) {
  {'stringValue': final Object? v} => '$v',
  {'intValue': final Object? v} => '$v',
  {'doubleValue': final Object? v} => '$v',
  {'boolValue': final Object? v} => '$v',
  {'bytesValue': final Object? v} => '$v',
  {'arrayValue': final Map<Object?, Object?> array} =>
    '[${(array['values'] as List<Object?>? ?? const []).map(_anyValue).join(', ')}]',
  {'kvlistValue': final Map<Object?, Object?> list} =>
    '{${(list['values'] as List<Object?>? ?? const []).cast<Map<Object?, Object?>>().map((kv) => '${kv['key']}: ${_anyValue(kv['value'])}').join(', ')}}',
  _ => '',
};

List<WireLabel> _attributes(Object? attributes, {String prefix = ''}) => [
  for (final attribute in (attributes as List<Object?>? ?? const []).cast<Map<Object?, Object?>>())
    WireLabel('$prefix${attribute['key']}', _anyValue(attribute['value'])),
];

String _status(Object? code) => switch (code) {
  1 || '1' || 'STATUS_CODE_OK' => 'ok',
  2 || '2' || 'STATUS_CODE_ERROR' => 'error',
  _ => 'unset',
};

/// Parses Tempo's OTLP JSON: `trace.resourceSpans` (v2 API), or `batches` with
/// `scopeSpans` or `instrumentationLibrarySpans` (v1 API). Spans are sorted by
/// start time; resource attributes follow the span's with a `resource.` prefix.
List<WireSpan> parseTempoTrace(Map<Object?, Object?> json) {
  final trace = json['trace'] is Map ? json['trace'] as Map<Object?, Object?> : json;
  final resources =
      (trace['resourceSpans'] ?? trace['batches'] ?? json['batches']) as List<Object?>? ?? const [];
  final spans = <(int, WireSpan)>[];
  for (final resource in resources.cast<Map<Object?, Object?>>()) {
    final resourceAttributes =
        (resource['resource'] as Map<Object?, Object?>?)?['attributes'] ?? const <Object?>[];
    final service =
        _attributes(resourceAttributes).where((a) => a.name == 'service.name').firstOrNull?.value ??
        'unknown';
    final scopes =
        (resource['scopeSpans'] ?? resource['instrumentationLibrarySpans']) as List<Object?>? ??
        const [];
    for (final scope in scopes.cast<Map<Object?, Object?>>()) {
      for (final span
          in (scope['spans'] as List<Object?>? ?? const []).cast<Map<Object?, Object?>>()) {
        final start = int.tryParse('${span['startTimeUnixNano']}') ?? 0;
        final end = int.tryParse('${span['endTimeUnixNano']}') ?? start;
        final status = span['status'] as Map<Object?, Object?>? ?? const {};
        final message = status['message'] as String?;
        spans.add((
          start,
          WireSpan(
            spanId: _spanId(span['spanId']) ?? '',
            parentSpanId: _spanId(span['parentSpanId']),
            name: '${span['name'] ?? ''}',
            service: service,
            start: DateTime.fromMicrosecondsSinceEpoch(start ~/ 1000, isUtc: true),
            durationMs: (end - start) / 1e6,
            status: _status(status['code']),
            statusMessage: message == null || message.isEmpty ? null : message,
            attributes: [
              ..._attributes(span['attributes']),
              ..._attributes(resourceAttributes, prefix: 'resource.'),
            ],
          ),
        ));
      }
    }
  }
  spans.sort((a, b) => a.$1.compareTo(b.$1));
  return [for (final (_, span) in spans) span];
}

/// Tag names from a v2 tags response as TraceQL attributes (`span.x`,
/// `resource.y`; intrinsics stay bare), or the values of a tag.
List<String> parseTempoTags(Object? json, {required bool values}) {
  if (values) {
    final list = json is Map ? json['tagValues'] ?? json['values'] : null;
    return [
      for (final value in (list as List<Object?>? ?? const []))
        if (value is Map) '${value['value']}' else '$value',
    ];
  }
  final scopes = json is Map ? json['scopes'] as List<Object?>? : null;
  return [
    for (final scope in (scopes ?? const []).cast<Map<Object?, Object?>>())
      for (final tag in (scope['tags'] as List<Object?>? ?? const []))
        scope['name'] == 'intrinsic' ? '$tag' : '${scope['name']}.$tag',
  ];
}
