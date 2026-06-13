import 'dart:convert';
import 'dart:io';

import 'package:hippo_cli_core/hippo_cli_core.dart';

final class ServerBenchmarkConfig {
  const ServerBenchmarkConfig({
    required this.url,
    this.method = 'GET',
    this.headers = const {},
    this.duration = const Duration(seconds: 30),
    this.warmup = const Duration(seconds: 5),
    this.concurrency = 16,
    this.outputPath = 'build/reports/bench/server.json',
    this.maxP95LatencyMs,
    this.minThroughput,
  });

  final Uri url;
  final String method;
  final Map<String, String> headers;
  final Duration duration;
  final Duration warmup;
  final int concurrency;
  final String outputPath;
  final double? maxP95LatencyMs;
  final double? minThroughput;
}

final class ServerBenchmarkResult {
  const ServerBenchmarkResult({
    required this.requests,
    required this.failures,
    required this.throughput,
    required this.p95LatencyMs,
  });

  final int requests;
  final int failures;
  final double throughput;
  final double p95LatencyMs;

  Map<String, Object?> toJsonMap() => {
    'requests': requests,
    'failures': failures,
    'throughput': throughput,
    'p95_latency_ms': p95LatencyMs,
  };
}

final class ServerBenchmarkRunner {
  const ServerBenchmarkRunner();

  Future<ServerBenchmarkResult> run(ServerBenchmarkConfig config) async {
    final client = HttpClient();
    final latencies = <int>[];
    var requests = 0;
    var failures = 0;
    try {
      await _runFor(client, config, config.warmup, record: false, latencies: latencies);
      final started = DateTime.now();
      await Future.wait([
        for (var i = 0; i < config.concurrency; i++)
          _runFor(client, config, config.duration, record: true, latencies: latencies).then((
            result,
          ) {
            requests += result.requests;
            failures += result.failures;
          }),
      ]);
      final elapsed = DateTime.now().difference(started).inMilliseconds / 1000;
      latencies.sort();
      final p95Index = latencies.isEmpty
          ? 0
          : (latencies.length * 0.95).floor().clamp(0, latencies.length - 1);
      final p95 = latencies.isEmpty ? 0.0 : latencies[p95Index].toDouble();
      final result = ServerBenchmarkResult(
        requests: requests,
        failures: failures,
        throughput: elapsed <= 0 ? 0 : requests / elapsed,
        p95LatencyMs: p95,
      );
      await _writeReport(config.outputPath, result);
      _validateThresholds(config, result);
      return result;
    } finally {
      client.close(force: true);
    }
  }

  Future<_RunResult> _runFor(
    HttpClient client,
    ServerBenchmarkConfig config,
    Duration duration, {
    required bool record,
    required List<int> latencies,
  }) async {
    final deadline = DateTime.now().add(duration);
    var requests = 0;
    var failures = 0;
    while (DateTime.now().isBefore(deadline)) {
      final stopwatch = Stopwatch()..start();
      try {
        final request = await client.openUrl(config.method, config.url);
        for (final entry in config.headers.entries) {
          request.headers.set(entry.key, entry.value);
        }
        final response = await request.close();
        await response.drain<void>();
        if (response.statusCode >= 500) {
          failures++;
        }
      } on Object {
        failures++;
      } finally {
        stopwatch.stop();
        if (record) {
          requests++;
          latencies.add(stopwatch.elapsedMilliseconds);
        }
      }
    }
    return _RunResult(requests: requests, failures: failures);
  }
}

final class _RunResult {
  const _RunResult({required this.requests, required this.failures});

  final int requests;
  final int failures;
}

Future<void> _writeReport(String outputPath, ServerBenchmarkResult result) async {
  final file = File(outputPath);
  await file.parent.create(recursive: true);
  await file.writeAsString('${const JsonEncoder.withIndent('  ').convert(result.toJsonMap())}\n');
}

void _validateThresholds(ServerBenchmarkConfig config, ServerBenchmarkResult result) {
  if (config.maxP95LatencyMs != null && result.p95LatencyMs > config.maxP95LatencyMs!) {
    throw HippoException(
      'Benchmark p95 latency exceeded the threshold.',
      expected: 'Expected <= ${config.maxP95LatencyMs}ms, got ${result.p95LatencyMs}ms.',
      exitCode: HippoExitCode.unavailable,
    );
  }
  if (config.minThroughput != null && result.throughput < config.minThroughput!) {
    throw HippoException(
      'Benchmark throughput missed the threshold.',
      expected: 'Expected >= ${config.minThroughput} req/s, got ${result.throughput} req/s.',
      exitCode: HippoExitCode.unavailable,
    );
  }
}
