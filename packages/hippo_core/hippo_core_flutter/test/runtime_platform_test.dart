import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hippo_core/hippo_core.dart';
import 'package:hippo_core_flutter/hippo_core_flutter.dart';

void main() {
  tearDown(() => debugDefaultTargetPlatformOverride = null);

  test('maps Flutter target platforms to runtime platforms', () {
    debugDefaultTargetPlatformOverride = TargetPlatform.windows;
    expect(currentRuntimePlatform, RuntimePlatform.windows);

    debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
    expect(currentRuntimePlatform, RuntimePlatform.iOS);
  });
}
