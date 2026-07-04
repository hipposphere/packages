import 'package:args/command_runner.dart';
import 'package:hippo_cli_build/hippo_cli_build.dart';
import 'package:hippo_cli_core/hippo_cli_core.dart';

import '../hippo_command.dart';

final class ServerBenchCommand extends HippoCommand {
  ServerBenchCommand(super.contextFactory) {
    argParser
      ..addOption('url', mandatory: true, help: 'HTTP endpoint to benchmark.')
      ..addOption('method', defaultsTo: 'GET', help: 'HTTP method.')
      ..addMultiOption('header', help: 'HTTP header in "Name: value" format.')
      ..addOption('duration', defaultsTo: '30', help: 'Benchmark duration in seconds.')
      ..addOption('warmup', defaultsTo: '5', help: 'Warmup duration in seconds.')
      ..addOption('concurrency', defaultsTo: '16', help: 'Concurrent request loops.')
      ..addOption(
        'output',
        defaultsTo: 'build/reports/bench/server.json',
        help: 'JSON report path.',
      )
      ..addOption('max-p95-latency-ms', help: 'Fail if p95 latency exceeds this threshold.')
      ..addOption('min-throughput', help: 'Fail if throughput is below this req/s threshold.');
  }

  @override
  String get name => 'server';

  @override
  String get description => 'Benchmark a server HTTP endpoint.';

  @override
  Future<int> run() async {
    final ctx = await context;
    final result = await ServerBenchmarkRunner().run(
      ServerBenchmarkConfig(
        url: Uri.parse(argResults!.option('url')!),
        method: argResults!.option('method')!,
        headers: _parseHeaders(argResults!.multiOption('header')),
        duration: Duration(seconds: int.parse(argResults!.option('duration')!)),
        warmup: Duration(seconds: int.parse(argResults!.option('warmup')!)),
        concurrency: int.parse(argResults!.option('concurrency')!),
        outputPath: argResults!.option('output')!,
        maxP95LatencyMs: _tryParseDouble(argResults!.option('max-p95-latency-ms')),
        minThroughput: _tryParseDouble(argResults!.option('min-throughput')),
      ),
    );
    ctx.console.ok('benchmark', '${result.throughput.toStringAsFixed(1)} req/s');
    return HippoExitCode.ok;
  }
}

Map<String, String> _parseHeaders(List<String> values) {
  final headers = <String, String>{};
  for (final value in values) {
    final separator = value.indexOf(':');
    if (separator <= 0) {
      throw UsageException('Expected --header values in "Name: value" format.', '');
    }
    headers[value.substring(0, separator).trim()] = value.substring(separator + 1).trim();
  }
  return headers;
}

double? _tryParseDouble(String? value) {
  if (value == null || value.isEmpty) {
    return null;
  }
  return double.parse(value);
}
