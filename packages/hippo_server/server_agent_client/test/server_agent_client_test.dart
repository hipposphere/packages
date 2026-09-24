import 'package:server_agent_client/server_agent_client.dart';
import 'package:test/test.dart';

void main() {
  test('command request round-trips through JSON framing', () async {
    const request = ServerAgentRequest(
      requestId: 'request-1',
      operation: ServerAgentOperation.restartContainer,
      arguments: <String, Object?>{'id': 'container-1'},
      timeout: Duration(seconds: 15),
    );
    final bytes = encodeServerAgentFrame(request.toJson());
    final decodedFrame = await decodeServerAgentFrames(Stream.value(bytes)).single;
    final decoded = ServerAgentRequest.fromJson(decodedFrame);

    expect(decoded.requestId, request.requestId);
    expect(decoded.operation, request.operation);
    expect(decoded.arguments, request.arguments);
    expect(decoded.timeout, request.timeout);
  });

  test('status round-trips through JSON', () {
    final status = ServerAgentStatus(
      capturedAt: DateTime.utc(2026, 9, 24, 12),
      capabilities: const {ServerAgentCapability.docker, ServerAgentCapability.system},
      docker: const DockerAgentStatus(
        engineVersion: '29.0.0',
        apiVersion: '1.46',
        operatingSystem: 'linux',
        architecture: 'amd64',
        containerCount: 4,
        runningContainerCount: 3,
      ),
      system: const SystemAgentStatus(
        hostname: 'hippo-test',
        cpuUsagePercent: 12.5,
        logicalCpuCount: 8,
        memoryTotalBytes: 16000000000,
        memoryUsedBytes: 8000000000,
        memoryAvailableBytes: 8000000000,
        diskTotalBytes: 100000000000,
        diskUsedBytes: 40000000000,
        diskAvailableBytes: 60000000000,
        uptime: Duration(hours: 4),
        loadAverage1Minute: 0.8,
      ),
      issues: const [],
    );

    final decoded = ServerAgentStatus.fromJson(status.toJson());

    expect(decoded.docker?.runningContainerCount, 3);
    expect(decoded.system?.memoryUsagePercent, 50);
    expect(decoded.system?.diskUsagePercent, 40);
  });
}
