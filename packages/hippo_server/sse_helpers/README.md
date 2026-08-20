# sse_helpers

Bounded, incremental Server-Sent Events decoding for Dart Edge clients and ordinary Dart byte
streams. The package reuses `SseEvent` from `dart_edge_core`; it does not define a parallel event
model or HTTP transport.

```dart
final response = await client.sendStream(request);
await for (final event in decodeSseEvents(response.bodyStream)) {
  print('${event.event}: ${event.data}');
}
```

Use `SseDecodeLimits` to set memory bounds appropriate for the upstream service:

```dart
const limits = SseDecodeLimits(
  maxLineBytes: 64 * 1024,
  maxFrameBytes: 1024 * 1024,
  maxDataLines: 256,
  maxEventNameBytes: 256,
);

final events = decodeSseEvents(response.bodyStream, limits: limits);
```

The decoder accepts fragmented UTF-8 input, LF, CRLF, and CR line endings, multiline `data` and
comment fields, `id`, and valid non-negative `retry` hints. Unknown fields and invalid retry hints
are ignored as required by the SSE protocol. Malformed UTF-8 and configured limit violations raise
an `SseDecodeException` without including upstream payload contents.
