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
      fileSystem.readText(_rootFile('/etc/hostname')),
      Future<void>.delayed(sampleDuration),
    ]);
    final secondCpu = await _cpuSample();
    final memory = _memoryUsage(values[0] as String);
    final uptimeSeconds = _firstDouble(values[1] as String);
    final loadAverage = _firstDouble(values[2] as String);
    final totalDelta = secondCpu.totalTicks - firstCpu.totalTicks;
    final idleDelta = secondCpu.idleTicks - firstCpu.idleTicks;
    final cpuUsage = _usagePercent(totalDelta, idleDelta);
    final coreCount = firstCpu.cores.length < secondCpu.cores.length
        ? firstCpu.cores.length
        : secondCpu.cores.length;
    final coreUsage = <double>[
      for (var index = 0; index < coreCount; index++)
        _usagePercent(
          secondCpu.cores[index].totalTicks - firstCpu.cores[index].totalTicks,
          secondCpu.cores[index].idleTicks - firstCpu.cores[index].idleTicks,
        ),
    ];

    return LinuxSystemMetrics(
      hostname: (values[3] as String).trim(),
      cpuUsagePercent: cpuUsage,
      cpuCoreUsagePercents: coreUsage,
      logicalCpuCount: secondCpu.logicalCpuCount,
      memory: memory,
      rootFileSystem: nativeSystem.fileSystemCapacity(rootPath),
      uptime: Duration(milliseconds: (uptimeSeconds * 1000).round()),
      loadAverage1Minute: loadAverage,
    );
  }

  String _rootFile(String path) => rootPath == '/' ? path : '$rootPath$path';

  Future<_CpuSample> _cpuSample() async {
    final lines = (await fileSystem.readText('$procPath/stat')).split('\n');
    final aggregate = _parseCpuLine(lines.firstWhere((line) => line.startsWith('cpu ')));
    final cores = <_CpuTicks>[];
    for (final line in lines) {
      if (RegExp(r'^cpu\d+\s').hasMatch(line)) cores.add(_parseCpuLine(line));
    }
    return _CpuSample(total: aggregate, cores: cores);
  }
}

_CpuTicks _parseCpuLine(String line) {
  final values = line.trim().split(RegExp(r'\s+')).skip(1).map(int.parse).toList();
  if (values.length < 5) {
    throw const FormatException('Invalid /proc/stat CPU line.');
  }
  return _CpuTicks(
    totalTicks: values.take(8).fold<int>(0, (total, value) => total + value),
    idleTicks: values[3] + values[4],
  );
}

double _usagePercent(int totalDelta, int idleDelta) =>
    totalDelta <= 0 ? 0.0 : ((totalDelta - idleDelta) / totalDelta * 100).clamp(0, 100).toDouble();

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
  final free = values['MemFree'];
  final buffers = values['Buffers'];
  final cached = values['Cached'];
  final hasBreakdown = free != null && buffers != null && cached != null;
  return LinuxMemoryUsage(
    totalBytes: total,
    availableBytes: available.clamp(0, total),
    freeBytes: hasBreakdown ? free.clamp(0, total) : null,
    cacheBytes: hasBreakdown
        ? (buffers + cached + (values['SReclaimable'] ?? 0)).clamp(0, total)
        : null,
  );
}

double _firstDouble(String source) => double.parse(source.trim().split(RegExp(r'\s+')).first);

final class _CpuTicks {
  const _CpuTicks({required this.totalTicks, required this.idleTicks});

  final int totalTicks;
  final int idleTicks;
}

final class _CpuSample {
  const _CpuSample({required this.total, required this.cores});

  final _CpuTicks total;
  final List<_CpuTicks> cores;

  int get totalTicks => total.totalTicks;
  int get idleTicks => total.idleTicks;
  int get logicalCpuCount => cores.length;
}
