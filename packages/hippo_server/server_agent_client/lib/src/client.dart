import 'dart:io';

import 'package:server_agent_client/src/framing.dart';
import 'package:server_agent_client/src/messages.dart';
import 'package:server_agent_client/src/status.dart';

final class ServerAgentException implements Exception {
  const ServerAgentException(this.code, this.message, [this.details = const {}]);

  final String code;
  final String message;
  final JsonObject details;

  @override
  String toString() => 'ServerAgentException($code): $message';
}

final class ServerAgentClient {
  ServerAgentClient({required this.socketPath, this.timeout = const Duration(seconds: 30)});

  final String socketPath;
  final Duration timeout;
  int _sequence = 0;

  Future<ServerAgentStatus> status() async =>
      ServerAgentStatus.fromJson(await execute(ServerAgentOperation.status));

  Future<List<JsonObject>> listContainers() async {
    final result = await execute(ServerAgentOperation.listContainers);
    final containers = result['containers'];
    if (containers is! List) {
      throw const FormatException('containers must be a list.');
    }
    return containers
        .map((container) => jsonObject(container, field: 'container'))
        .toList(growable: false);
  }

  Future<JsonObject> inspectContainer(String id) =>
      execute(ServerAgentOperation.inspectContainer, arguments: <String, Object?>{'id': id});

  Future<JsonObject> containerStats(String id) =>
      execute(ServerAgentOperation.containerStats, arguments: <String, Object?>{'id': id});

  Future<JsonObject> execute(
    ServerAgentOperation operation, {
    JsonObject arguments = const {},
    Duration? commandTimeout,
  }) async {
    final request = ServerAgentRequest(
      requestId: '${DateTime.now().microsecondsSinceEpoch}-${_sequence++}',
      operation: operation,
      arguments: arguments,
      timeout: commandTimeout,
    );
    final socket = await Socket.connect(
      InternetAddress(socketPath, type: InternetAddressType.unix),
      0,
    ).timeout(timeout);
    try {
      await writeServerAgentFrame(socket, request.toJson()).timeout(timeout);
      final response = ServerAgentResponse.fromJson(
        await decodeServerAgentFrames(socket).first.timeout(commandTimeout ?? timeout),
      );
      if (response.protocolVersion != serverAgentProtocolVersion) {
        throw ServerAgentException(
          'protocol_version',
          'Unsupported protocol version ${response.protocolVersion}.',
        );
      }
      if (response.requestId != request.requestId) {
        throw const ServerAgentException('request_mismatch', 'Response request ID did not match.');
      }
      if (!response.success) {
        throw ServerAgentException(
          response.error?.code ?? 'unknown',
          response.error?.message ?? 'Server-agent request failed.',
          response.error?.details ?? const {},
        );
      }
      return response.result;
    } finally {
      await socket.close();
    }
  }
}
