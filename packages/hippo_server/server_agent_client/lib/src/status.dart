typedef JsonObject = Map<String, Object?>;

enum ServerAgentCapability {
  docker,
  system,
  host;

  static ServerAgentCapability fromJson(Object? value) => values.firstWhere(
    (capability) => capability.name == value,
    orElse: () => throw FormatException('Unknown server-agent capability: $value'),
  );
}

final class SystemAgentStatus {
  const SystemAgentStatus({
    required this.hostname,
    required this.cpuUsagePercent,
    required this.logicalCpuCount,
    required this.memoryTotalBytes,
    required this.memoryUsedBytes,
    required this.memoryAvailableBytes,
    required this.diskTotalBytes,
    required this.diskUsedBytes,
    required this.diskAvailableBytes,
    required this.uptime,
    required this.loadAverage1Minute,
  });

  factory SystemAgentStatus.fromJson(JsonObject json) => SystemAgentStatus(
    hostname: _requiredString(json, 'hostname'),
    cpuUsagePercent: _requiredDouble(json, 'cpuUsagePercent'),
    logicalCpuCount: _requiredInt(json, 'logicalCpuCount'),
    memoryTotalBytes: _requiredInt(json, 'memoryTotalBytes'),
    memoryUsedBytes: _requiredInt(json, 'memoryUsedBytes'),
    memoryAvailableBytes: _requiredInt(json, 'memoryAvailableBytes'),
    diskTotalBytes: _requiredInt(json, 'diskTotalBytes'),
    diskUsedBytes: _requiredInt(json, 'diskUsedBytes'),
    diskAvailableBytes: _requiredInt(json, 'diskAvailableBytes'),
    uptime: Duration(milliseconds: _requiredInt(json, 'uptimeMilliseconds')),
    loadAverage1Minute: _requiredDouble(json, 'loadAverage1Minute'),
  );

  final String hostname;
  final double cpuUsagePercent;
  final int logicalCpuCount;
  final int memoryTotalBytes;
  final int memoryUsedBytes;
  final int memoryAvailableBytes;
  final int diskTotalBytes;
  final int diskUsedBytes;
  final int diskAvailableBytes;
  final Duration uptime;
  final double loadAverage1Minute;

  double get memoryUsagePercent =>
      memoryTotalBytes == 0 ? 0 : memoryUsedBytes / memoryTotalBytes * 100;
  double get diskUsagePercent => diskTotalBytes == 0 ? 0 : diskUsedBytes / diskTotalBytes * 100;

  JsonObject toJson() => {
    'hostname': hostname,
    'cpuUsagePercent': cpuUsagePercent,
    'logicalCpuCount': logicalCpuCount,
    'memoryTotalBytes': memoryTotalBytes,
    'memoryUsedBytes': memoryUsedBytes,
    'memoryAvailableBytes': memoryAvailableBytes,
    'diskTotalBytes': diskTotalBytes,
    'diskUsedBytes': diskUsedBytes,
    'diskAvailableBytes': diskAvailableBytes,
    'uptimeMilliseconds': uptime.inMilliseconds,
    'loadAverage1Minute': loadAverage1Minute,
  };
}

final class DockerAgentStatus {
  const DockerAgentStatus({
    required this.engineVersion,
    required this.apiVersion,
    required this.operatingSystem,
    required this.architecture,
    required this.containerCount,
    required this.runningContainerCount,
  });

  factory DockerAgentStatus.fromJson(JsonObject json) => DockerAgentStatus(
    engineVersion: _requiredString(json, 'engineVersion'),
    apiVersion: _requiredString(json, 'apiVersion'),
    operatingSystem: _optionalString(json, 'operatingSystem'),
    architecture: _optionalString(json, 'architecture'),
    containerCount: _requiredInt(json, 'containerCount'),
    runningContainerCount: _requiredInt(json, 'runningContainerCount'),
  );

  final String engineVersion;
  final String apiVersion;
  final String? operatingSystem;
  final String? architecture;
  final int containerCount;
  final int runningContainerCount;

  JsonObject toJson() => {
    'engineVersion': engineVersion,
    'apiVersion': apiVersion,
    'operatingSystem': operatingSystem,
    'architecture': architecture,
    'containerCount': containerCount,
    'runningContainerCount': runningContainerCount,
  };
}

final class HostAgentStatus {
  const HostAgentStatus({
    required this.hostname,
    required this.operatingSystemName,
    required this.operatingSystemVersion,
    required this.kernelVersion,
    required this.architecture,
    required this.logicalCpuCount,
    required this.uptime,
  });

  factory HostAgentStatus.fromJson(JsonObject json) => HostAgentStatus(
    hostname: _requiredString(json, 'hostname'),
    operatingSystemName: _optionalString(json, 'operatingSystemName'),
    operatingSystemVersion: _optionalString(json, 'operatingSystemVersion'),
    kernelVersion: _requiredString(json, 'kernelVersion'),
    architecture: _requiredString(json, 'architecture'),
    logicalCpuCount: _requiredInt(json, 'logicalCpuCount'),
    uptime: Duration(milliseconds: _requiredInt(json, 'uptimeMilliseconds')),
  );

  final String hostname;
  final String? operatingSystemName;
  final String? operatingSystemVersion;
  final String kernelVersion;
  final String architecture;
  final int logicalCpuCount;
  final Duration uptime;

  JsonObject toJson() => {
    'hostname': hostname,
    'operatingSystemName': operatingSystemName,
    'operatingSystemVersion': operatingSystemVersion,
    'kernelVersion': kernelVersion,
    'architecture': architecture,
    'logicalCpuCount': logicalCpuCount,
    'uptimeMilliseconds': uptime.inMilliseconds,
  };
}

final class ServerAgentIssue {
  const ServerAgentIssue({required this.source, required this.message});

  factory ServerAgentIssue.fromJson(JsonObject json) => ServerAgentIssue(
    source: _requiredString(json, 'source'),
    message: _requiredString(json, 'message'),
  );

  final String source;
  final String message;

  JsonObject toJson() => {'source': source, 'message': message};
}

final class ServerAgentStatus {
  const ServerAgentStatus({
    required this.capturedAt,
    required this.capabilities,
    required this.issues,
    this.docker,
    this.system,
    this.host,
  });

  factory ServerAgentStatus.fromJson(JsonObject json) => ServerAgentStatus(
    capturedAt: DateTime.parse(_requiredString(json, 'capturedAt')).toUtc(),
    capabilities: _requiredList(json, 'capabilities').map(ServerAgentCapability.fromJson).toSet(),
    docker: json['docker'] == null
        ? null
        : DockerAgentStatus.fromJson(_object(json['docker'], field: 'docker')),
    system: json['system'] == null
        ? null
        : SystemAgentStatus.fromJson(_object(json['system'], field: 'system')),
    host: json['host'] == null
        ? null
        : HostAgentStatus.fromJson(_object(json['host'], field: 'host')),
    issues: _requiredList(json, 'issues')
        .map((issue) => ServerAgentIssue.fromJson(_object(issue, field: 'issue')))
        .toList(growable: false),
  );

  final DateTime capturedAt;
  final Set<ServerAgentCapability> capabilities;
  final DockerAgentStatus? docker;
  final SystemAgentStatus? system;
  final HostAgentStatus? host;
  final List<ServerAgentIssue> issues;

  JsonObject toJson() => {
    'capturedAt': capturedAt.toUtc().toIso8601String(),
    'capabilities': capabilities.map((capability) => capability.name).toList(growable: false),
    'docker': docker?.toJson(),
    'system': system?.toJson(),
    'host': host?.toJson(),
    'issues': issues.map((issue) => issue.toJson()).toList(growable: false),
  };
}

JsonObject _object(Object? value, {required String field}) {
  if (value is! Map) throw FormatException('$field must be an object.');
  return value.map((key, value) => MapEntry(key.toString(), value));
}

List<Object?> _requiredList(JsonObject json, String field) {
  final value = json[field];
  if (value is List) return List<Object?>.from(value);
  throw FormatException('$field must be a list.');
}

String _requiredString(JsonObject json, String field) {
  final value = json[field];
  if (value is String && value.isNotEmpty) return value;
  throw FormatException('$field must be a non-empty string.');
}

String? _optionalString(JsonObject json, String field) {
  final value = json[field];
  if (value == null) return null;
  if (value is String) return value;
  throw FormatException('$field must be a string or null.');
}

int _requiredInt(JsonObject json, String field) {
  final value = json[field];
  if (value is int) return value;
  if (value is num) return value.toInt();
  throw FormatException('$field must be an integer.');
}

double _requiredDouble(JsonObject json, String field) {
  final value = json[field];
  if (value is num) return value.toDouble();
  throw FormatException('$field must be a number.');
}
