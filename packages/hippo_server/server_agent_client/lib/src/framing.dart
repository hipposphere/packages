import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:server_agent_client/src/messages.dart';
import 'package:server_agent_client/src/status.dart';

const defaultMaximumServerAgentFrameLength = 8 * 1024 * 1024;

Uint8List encodeServerAgentFrame(JsonObject message) {
  final payload = utf8.encode(jsonEncode(message));
  if (payload.isEmpty || payload.length > defaultMaximumServerAgentFrameLength) {
    throw RangeError.range(payload.length, 1, defaultMaximumServerAgentFrameLength, 'message');
  }
  final frame = Uint8List(4 + payload.length);
  ByteData.sublistView(frame).setUint32(0, payload.length, Endian.big);
  frame.setRange(4, frame.length, payload);
  return frame;
}

Future<void> writeServerAgentFrame(IOSink sink, JsonObject message) async {
  sink.add(encodeServerAgentFrame(message));
  await sink.flush();
}

Stream<JsonObject> decodeServerAgentFrames(
  Stream<List<int>> input, {
  int maximumFrameLength = defaultMaximumServerAgentFrameLength,
}) async* {
  var pending = <int>[];
  await for (final chunk in input) {
    pending = <int>[...pending, ...chunk];
    while (pending.length >= 4) {
      final length = ByteData.sublistView(
        Uint8List.fromList(pending),
        0,
        4,
      ).getUint32(0, Endian.big);
      if (length == 0 || length > maximumFrameLength) {
        throw FormatException('Invalid server-agent frame length: $length.');
      }
      final frameLength = 4 + length;
      if (pending.length < frameLength) break;
      final decoded = jsonDecode(utf8.decode(pending.sublist(4, frameLength)));
      pending = pending.sublist(frameLength);
      yield jsonObject(decoded, field: 'server-agent frame');
    }
  }
  if (pending.isNotEmpty) {
    throw const FormatException('Truncated server-agent frame.');
  }
}
