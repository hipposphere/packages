import 'dart:io';
import 'dart:isolate';

import 'package:hippo_analysis/hippo_analysis.dart';
import 'package:test/test.dart';

void main() {
  test('YAML and Dart formatter policies stay aligned', () async {
    final optionsUri = await Isolate.resolvePackageUri(
      Uri.parse('package:hippo_analysis/base.yaml'),
    );
    final options = File.fromUri(optionsUri!).readAsStringSync();

    expect(options, contains('page_width: $hippoFormatterPageWidth'));
    expect(options, contains('trailing_commas: ${hippoFormatterTrailingCommas.name}'));
  });

  test('Flutter analysis excludes generated build and platform directories', () async {
    final optionsUri = await Isolate.resolvePackageUri(
      Uri.parse('package:hippo_analysis/flutter.yaml'),
    );
    final options = File.fromUri(optionsUri!).readAsStringSync();

    for (final directory in ['build', 'android', 'ios', 'web', 'windows', 'macos', 'linux']) {
      expect(options, contains('- $directory/**'));
    }
  });

  test('shared formatter uses automatic trailing commas and a 100-column page', () {
    final formatted = createHippoDartFormatter().format('''
void main() {
  call('12345678901234567890123456789012345678901234567890', '12345678901234567890123456789012345678901234567890');
  call('short',);
}
''');

    expect(formatted, contains("  call(\n"));
    expect(formatted, contains("    '12345678901234567890123456789012345678901234567890',\n"));
    expect(formatted, contains("  );\n"));
    expect(formatted, contains("  call('short');\n"));
  });
}
