/*
// ---------------------------------------------------------------------------
// Copyright (c) 2025 HippoSphere UG (haftungsbeschränkt). All rights reserved.
// Use, copying, modification, or distribution of this software is prohibited
// without express written permission from Hipposphere UG.
//
// SPDX-License-Identifier: LicenseRef-Hipposphere-Proprietary
// ---------------------------------------------------------------------------
*/
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hippo_core_flutter/hippo_core_flutter.dart';

const _vsync = Duration(microseconds: Duration.microsecondsPerSecond ~/ 60);

void main() {
  testWidgets('limits state tickers without continuously scheduling frames', (tester) async {
    final key = GlobalKey<_AnimationHarnessState>();
    await tester.pumpWidget(_AnimationHarness(key: key));
    await tester.pump(_vsync);
    key.currentState!.tickCount = 0;

    for (var index = 0; index < 60; index++) {
      await tester.pump(_vsync);
      expect(tester.binding.hasScheduledFrame, isFalse);
    }

    expect(key.currentState!.tickCount, inInclusiveRange(28, 32));
  });

  testWidgets('updates the target rate when the widget changes', (tester) async {
    final key = GlobalKey<_AnimationHarnessState>();
    await tester.pumpWidget(_AnimationHarness(key: key, framesPerSecond: 15));
    await tester.pump(_vsync);
    key.currentState!.tickCount = 0;

    for (var index = 0; index < 60; index++) {
      await tester.pump(_vsync);
    }
    expect(key.currentState!.tickCount, inInclusiveRange(13, 17));

    await tester.pumpWidget(_AnimationHarness(key: key, framesPerSecond: 30));
    key.currentState!.tickCount = 0;
    for (var index = 0; index < 60; index++) {
      await tester.pump(_vsync);
    }
    expect(key.currentState!.tickCount, inInclusiveRange(28, 32));
  });
}

class _AnimationHarness extends StatefulWidget {
  const _AnimationHarness({this.framesPerSecond = 30, super.key});

  final double framesPerSecond;

  @override
  State<_AnimationHarness> createState() => _AnimationHarnessState();
}

class _AnimationHarnessState extends State<_AnimationHarness>
    with FrameRateTickerProviderStateMixin<_AnimationHarness> {
  AnimationController? _controller;
  var tickCount = 0;

  @override
  double get tickerFramesPerSecond => widget.framesPerSecond;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _controller ??= AnimationController(vsync: this, duration: const Duration(seconds: 4))
      ..addListener(() => tickCount++)
      ..repeat();
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => const SizedBox.shrink();
}
