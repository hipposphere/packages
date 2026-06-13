import 'package:hippo_cli_core/hippo_cli_core.dart';
import 'package:test/test.dart';

void main() {
  test('color mode always emits ansi styles', () {
    final out = StringBuffer();
    final console = HippoConsole(
      stdoutSink: out,
      stdoutIsTerminal: false,
      colorMode: HippoColorMode.always,
    );

    console.ok('workspace', 'ready');

    expect(out.toString(), contains('\x1B[32mOK\x1B[0m'));
  });

  test('ci mode disables decorative spinner output', () {
    final out = StringBuffer();
    final console = HippoConsole(stdoutSink: out, stdoutIsTerminal: true, ci: true);

    final spinner = console.spinner('Loading');

    expect(spinner.enabled, isFalse);
  });

  test('table renders deterministic fixed-width rows', () {
    final table = HippoTable(
      headers: const ['Name', 'Path'],
      rows: const [
        ['hippo-dev', '/very/long/path/to/skill'],
      ],
      maxWidth: 10,
    );

    expect(table.render(), contains('hippo-dev'));
    expect(table.render(), contains('/very/l...'));
  });

  test('structured errors include next steps', () {
    final err = StringBuffer();
    final console = HippoConsole(stderrSink: err, stderrIsTerminal: false);

    console.renderException(
      const HippoException(
        'Missing config.',
        expected: 'Expected config.yaml.',
        nextSteps: ['Create config.yaml.'],
      ),
    );

    expect(err.toString(), contains('Missing config.'));
    expect(err.toString(), contains('Expected config.yaml.'));
    expect(err.toString(), contains('Create config.yaml.'));
  });
}
