import 'dart:io';

import 'package:linux_host_inspector/linux_host_inspector.dart';
import 'package:test/test.dart';

void main() {
  test('reads aggregate metrics from configurable host mounts', () async {
    final inspector = LinuxSystemMetricsInspector(
      procPath: '/host/proc',
      rootPath: '/host/root',
      sampleDuration: Duration.zero,
      fileSystem: _SequenceFileSystem(<String, List<String>>{
        '/host/proc/stat': <String>[
          'cpu 100 0 0 900 0 0 0 0\ncpu0 50 0 0 450 0 0 0 0\ncpu1 50 0 0 450 0 0 0 0\n',
          'cpu 160 0 0 940 0 0 0 0\ncpu0 80 0 0 470 0 0 0 0\ncpu1 80 0 0 470 0 0 0 0\n',
        ],
        '/host/proc/meminfo': <String>['MemTotal: 1000 kB\nMemAvailable: 400 kB\n'],
        '/host/proc/uptime': <String>['3600.5 0\n'],
        '/host/proc/loadavg': <String>['0.75 0.50 0.25 1/100 1\n'],
        '/host/root/etc/hostname': <String>['hippo-test\n'],
      }),
      nativeSystem: const _NativeSystem(),
    );

    final metrics = await inspector.read();

    expect(metrics.hostname, 'hippo-test');
    expect(metrics.cpuUsagePercent, 60);
    expect(metrics.logicalCpuCount, 2);
    expect(metrics.cpuCoreUsagePercents, [60, 60]);
    expect(metrics.memory.freeBytes, isNull);
    expect(metrics.memory.processBytes, isNull);
    expect(metrics.memory.usedBytes, 600 * 1024);
    expect(metrics.rootFileSystem.totalBytes, 1000000);
    expect(metrics.uptime, const Duration(milliseconds: 3600500));
    expect(metrics.loadAverage1Minute, 0.75);
  });

  test('reports per-core usage and the memory breakdown', () async {
    final inspector = LinuxSystemMetricsInspector(
      procPath: '/host/proc',
      rootPath: '/host/root',
      sampleDuration: Duration.zero,
      fileSystem: _SequenceFileSystem(<String, List<String>>{
        '/host/proc/stat': <String>[
          'cpu 100 0 0 300 0 0 0 0\ncpu0 100 0 0 100 0 0 0 0\ncpu1 0 0 0 200 0 0 0 0\n',
          'cpu 150 0 0 350 0 0 0 0\ncpu0 150 0 0 100 0 0 0 0\ncpu1 0 0 0 250 0 0 0 0\n',
        ],
        '/host/proc/meminfo': <String>[
          'MemTotal: 1000 kB\nMemFree: 100 kB\nMemAvailable: 500 kB\n'
              'Buffers: 50 kB\nCached: 250 kB\nSReclaimable: 50 kB\n',
        ],
        '/host/proc/uptime': <String>['1.0 0\n'],
        '/host/proc/loadavg': <String>['0.1 0.1 0.1 1/1 1\n'],
        '/host/root/etc/hostname': <String>['hippo-test\n'],
      }),
      nativeSystem: const _NativeSystem(),
    );

    final metrics = await inspector.read();

    expect(metrics.cpuCoreUsagePercents, [100, 0]);
    expect(metrics.cpuUsagePercent, 50);
    expect(metrics.memory.freeBytes, 100 * 1024);
    expect(metrics.memory.cacheBytes, 350 * 1024);
    expect(metrics.memory.processBytes, 550 * 1024);
    expect(metrics.memory.availableBytes, 500 * 1024);
  });
}

final class _SequenceFileSystem implements LinuxSystemFileSystem {
  _SequenceFileSystem(this.values);

  final Map<String, List<String>> values;

  @override
  Future<String> readText(String path) async {
    final candidates = values[path];
    if (candidates == null || candidates.isEmpty) {
      throw FileSystemException('Missing file', path);
    }
    return candidates.length == 1 ? candidates.single : candidates.removeAt(0);
  }

  @override
  Future<List<String>> listDirectoryNames(String path) async => const [];
}

final class _NativeSystem implements LinuxNativeSystem {
  const _NativeSystem();

  @override
  String get architecture => 'x86_64';

  @override
  int get clockTicksPerSecond => 100;

  @override
  int get pageSize => 4096;

  @override
  LinuxFileSystemCapacity fileSystemCapacity(String path) {
    expect(path, '/host/root');
    return const LinuxFileSystemCapacity(
      totalBytes: 1000000,
      freeBytes: 400000,
      availableBytes: 300000,
    );
  }
}
