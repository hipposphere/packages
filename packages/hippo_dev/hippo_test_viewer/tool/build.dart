import 'dart:convert';
import 'dart:io';

/// Compile once when releasing hippo_test; consumers need neither Jaspr nor a web build.
/// Use --check in CI to reject an outdated committed viewer bundle.
Future<void> main(List<String> args) async {
  final root = File.fromUri(Platform.script).parent.parent;
  final output = Directory.fromUri(root.uri.resolve('../hippo_test_core/assets/'));
  final build = Directory('${root.path}/build')..createSync(recursive: true);
  final result = await Process.run(Platform.resolvedExecutable, [
    'compile',
    'js',
    '-O2',
    '--no-source-maps',
    '${root.path}/lib/main.client.dart',
    '-o',
    '${build.path}/viewer.js',
  ], workingDirectory: root.path);
  stdout.write(result.stdout);
  stderr.write(result.stderr);
  if (result.exitCode != 0) {
    exitCode = result.exitCode;
    return;
  }
  final sources = {
    'viewer.js': File('${build.path}/viewer.js'),
    'viewer.css': File('${root.path}/web/viewer.css'),
  };
  for (final entry in sources.entries) {
    final destination = File('${output.path}/${entry.key}');
    if (args.contains('--check')) {
      if (!destination.existsSync() ||
          base64Encode(destination.readAsBytesSync()) !=
              base64Encode(entry.value.readAsBytesSync())) {
        stderr.writeln('Stale bundle: ${entry.key}. Run tool/build.dart and commit the output.');
        exitCode = 1;
      }
    } else {
      output.createSync(recursive: true);
      entry.value.copySync(destination.path);
    }
  }
  if (exitCode == 0) {
    stdout.writeln(
      args.contains('--check')
          ? 'Viewer bundle matches source.'
          : 'Bundled Jaspr viewer in ${output.path}',
    );
  }
}
