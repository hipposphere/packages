import 'file_system.dart';
import 'models.dart';
import 'native_system.dart';

/// Lightweight aggregate CPU, memory, load, uptime, and root-disk sampling.
final class LinuxSystemMetricsInspector {
  LinuxSystemMetricsInspector({
    this.procPath = '/proc',
    this.rootPath = '/',
    this.sampleDuration = const Duration(milliseconds: 200),
    LinuxSystemFileSystem? fileSystem,
    LinuxNativeSystem? nativeSystem,
  }) : fileSystem = fileSystem ?? const IoLinuxSystemFileSystem(),
       nativeSystem = nativeSystem ?? LibcLinuxNativeSystem();

  final String procPath;
  final String rootPath;
  final Duration sampleDuration;
  final LinuxSystemFileSystem fileSystem;
  final LinuxNativeSystem nativeSystem;

  Future<LinuxSystemMetrics> read() async {
    final firstCpu = await _cpuSample();
    final values = await Future.wait<Object?>(<Future<Object?>>[
      fileSystem.readText('$procPath/meminfo'),
      fileSystem.readText('$procPath/uptime'),
      fileSystem.readText('$procPath/loadavg'),
      fileSystem.readText('$procPath/sys/kernel/hostname'),
      Future<void>.delayed(sampleDuration),
    ]);
    final secondCpu = await _cpuSample();
    final memory = _memoryUsage(values[0] as String);
    final uptimeSeconds = _firstDouble(values[1] as String);
    final loadAverage = _firstDouble(values[2] as String);
    final totalDelta = secondCpu.totalTicks - firstCpu.totalTicks;
    final idleDelta = secondCpu.idleTicks - firstCpu.idleTicks;
    final cpuUsage = totalDelta <= 0
        ? 0.0
        : ((totalDelta - idleDelta) / totalDelta * 100).clamp(0, 100).toDouble();

    return LinuxSystemMetrics(
      hostname: (values[3] as String).trim(),
      cpuUsagePercent: cpuUsage,
      logicalCpuCount: secondCpu.logicalCpuCount,
      memory: memory,
      rootFileSystem: nativeSystem.fileSystemCapacity(rootPath),
      uptime: Duration(milliseconds: (uptimeSeconds * 1000).round()),
      loadAverage1Minute: loadAverage,
    );
  }

  Future<_CpuSample> _cpuSample() async {
    final lines = (await fileSystem.readText('$procPath/stat')).split('\n');
    final aggregate = lines.firstWhere((line) => line.startsWith('cpu '));
    final values = aggregate.trim().split(RegExp(r'\s+')).skip(1).map(int.parse).toList();
    if (values.length < 5) {
      throw const FormatException('Invalid /proc/stat CPU line.');
    }
    return _CpuSample(
      totalTicks: values.take(8).fold<int>(0, (total, value) => total + value),
      idleTicks: values[3] + values[4],
      logicalCpuCount: lines.where((line) => RegExp(r'^cpu\d+\s').hasMatch(line)).length,
    );
  }
}

LinuxMemoryUsage _memoryUsage(String source) {
  final values = <String, int>{};
  for (final line in source.split('\n')) {
    final match = RegExp(r'^([^:]+):\s+(\d+)').firstMatch(line);
    if (match != null) {
      values[match.group(1)!] = int.parse(match.group(2)!) * 1024;
    }
  }
  final total = values['MemTotal'];
  if (total == null) {
    throw const FormatException('MemTotal is missing from /proc/meminfo.');
  }
  final available =
      values['MemAvailable'] ??
      (values['MemFree'] ?? 0) + (values['Buffers'] ?? 0) + (values['Cached'] ?? 0);
  return LinuxMemoryUsage(totalBytes: total, availableBytes: available.clamp(0, total));
}

double _firstDouble(String source) => double.parse(source.trim().split(RegExp(r'\s+')).first);

final class _CpuSample {
  const _CpuSample({
    required this.totalTicks,
    required this.idleTicks,
    required this.logicalCpuCount,
  });

  final int totalTicks;
  final int idleTicks;
  final int logicalCpuCount;
}
