// Explicitly invoked by tool/verify_runner.dart; never included in normal tests.
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hippo_test/hippo_test.dart';

void main() {
  featureTest(
    'probe.golden',
    'A changed golden must fail and retain comparison images',
    loadFonts: false,
    run: (test) async {
      const changed = bool.fromEnvironment('HIPPO_PROBE_CHANGED');
      await test.mount(const ColoredBox(color: changed ? Color(0xffff0000) : Color(0xff0000ff)));
      await test.step('Compare color', () => test.checkpoint('Color', golden: 'goldens/probe.png'));
    },
  );
  featureTest(
    'probe.teardown',
    'A late teardown failure must be red in the report',
    loadFonts: false,
    run: (test) async {
      if (const bool.fromEnvironment('HIPPO_PROBE_CHANGED')) {
        addTearDown(() => throw StateError('intentional teardown failure'));
      }
      await test.mount(const SizedBox());
    },
  );
}
