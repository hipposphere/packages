import 'package:server_agent_client/src/status.dart';

const serverAgentProtocolVersion = 1;

enum ServerAgentOperation {
  status('status'),
  listContainers('docker.container.list'),
  inspectContainer('docker.container.inspect'),
  containerStats('docker.container.stats'),
  containerLogs('docker.container.logs'),
  startContainer('docker.container.start'),
  stopContainer('docker.container.stop'),
  restartContainer('docker.container.restart'),
  createContainer('docker.container.create'),
  removeContainer('docker.container.remove'),
  pullImage('docker.image.pull'),
  composeValidate('compose.validate'),
  composePs('compose.ps'),
  composeLogs('compose.logs'),
  composePull('compose.pull'),
  composeUp('compose.up'),
  composeDown('compose.down'),
  composeStart('compose.start'),
  composeStop('compose.stop'),
  composeRestart('compose.restart');

  const ServerAgentOperation(this.wireName);
  final String wireName;

  static ServerAgentOperation? fromWireName(String value) {
    for (final operation in values) {
      if (operation.wireName == value) return operation;
    }
    return null;
  }
}

final class ServerAgentRequest {
  const ServerAgentRequest({
    required this.requestId,
    required this.operation,
    this.arguments = const {},
    this.timeout,
    this.protocolVersion = serverAgentProtocolVersion,
  });

  factory ServerAgentRequest.fromJson(JsonObject json) => ServerAgentRequest(
    requestId: requiredString(json, 'requestId'),
    operation:
        ServerAgentOperation.fromWireName(requiredString(json, 'operation')) ??
        (throw FormatException('Unsupported server-agent operation: ${json['operation']}')),
    arguments: jsonObject(json['arguments'], field: 'arguments'),
    timeout: json['timeoutMilliseconds'] == null
        ? null
        : Duration(milliseconds: requiredInt(json, 'timeoutMilliseconds')),
    protocolVersion: requiredInt(json, 'protocolVersion'),
  );

  final int protocolVersion;
  final String requestId;
  final ServerAgentOperation operation;
  final JsonObject arguments;
  final Duration? timeout;

  JsonObject toJson() => <String, Object?>{
    'protocolVersion': protocolVersion,
    'requestId': requestId,
    'operation': operation.wireName,
    'arguments': arguments,
    if (timeout case final timeout?) 'timeoutMilliseconds': timeout.inMilliseconds,
  };
}

final class ServerAgentError {
  const ServerAgentError({required this.code, required this.message, this.details = const {}});

  factory ServerAgentError.fromJson(JsonObject json) => ServerAgentError(
    code: requiredString(json, 'code'),
    message: requiredString(json, 'message'),
    details: jsonObject(json['details'], field: 'details'),
  );

  final String code;
  final String message;
  final JsonObject details;

  JsonObject toJson() => <String, Object?>{
    'code': code,
    'message': message,
    if (details.isNotEmpty) 'details': details,
  };
}

final class ServerAgentResponse {
  const ServerAgentResponse({
    required this.requestId,
    required this.success,
    this.result = const {},
    this.error,
    this.protocolVersion = serverAgentProtocolVersion,
  });

  factory ServerAgentResponse.success({required String requestId, JsonObject result = const {}}) =>
      ServerAgentResponse(requestId: requestId, success: true, result: result);

  factory ServerAgentResponse.failure({
    required String requestId,
    required String code,
    required String message,
    JsonObject details = const {},
  }) => ServerAgentResponse(
    requestId: requestId,
    success: false,
    error: ServerAgentError(code: code, message: message, details: details),
  );

  factory ServerAgentResponse.fromJson(JsonObject json) {
    final success = requiredBool(json, 'success');
    return ServerAgentResponse(
      requestId: requiredString(json, 'requestId'),
      success: success,
      result: jsonObject(json['result'], field: 'result'),
      error: json['error'] == null
          ? null
          : ServerAgentError.fromJson(jsonObject(json['error'], field: 'error')),
      protocolVersion: requiredInt(json, 'protocolVersion'),
    );
  }

  final int protocolVersion;
  final String requestId;
  final bool success;
  final JsonObject result;
  final ServerAgentError? error;

  JsonObject toJson() => <String, Object?>{
    'protocolVersion': protocolVersion,
    'requestId': requestId,
    'success': success,
    'result': result,
    if (error case final error?) 'error': error.toJson(),
  };
}

JsonObject jsonObject(Object? value, {required String field}) {
  if (value == null) return const <String, Object?>{};
  if (value is! Map) throw FormatException('$field must be an object.');
  return value.map((key, value) => MapEntry(key.toString(), value));
}

String requiredString(JsonObject json, String field) {
  final value = json[field];
  if (value is String && value.isNotEmpty) return value;
  throw FormatException('$field must be a non-empty string.');
}

int requiredInt(JsonObject json, String field) {
  final value = json[field];
  if (value is int) return value;
  if (value is num) return value.toInt();
  throw FormatException('$field must be an integer.');
}

bool requiredBool(JsonObject json, String field) {
  final value = json[field];
  if (value is bool) return value;
  throw FormatException('$field must be a boolean.');
}
