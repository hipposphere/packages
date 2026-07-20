import 'dart:io';

const _rustVersion = '1.95.0';

Future<void> main() async {
  final result = await Process.run('rustup', [
    'run',
    _rustVersion,
    'cargo',
    'build',
    '--manifest-path',
    'native/Cargo.toml',
    '--target',
    'wasm32-unknown-unknown',
    '--release',
    '--locked',
  ], runInShell: Platform.isWindows);
  stdout.write(result.stdout);
  stderr.write(result.stderr);
  if (result.exitCode != 0) {
    exitCode = result.exitCode;
    return;
  }

  const source = 'native/target/wasm32-unknown-unknown/release/hippo_zstandard_native.wasm';
  const destination = 'web/hippo_zstandard.wasm';
  await File(source).copy(destination);
  stdout.writeln('Wrote $destination (${await File(destination).length()} bytes).');
}
