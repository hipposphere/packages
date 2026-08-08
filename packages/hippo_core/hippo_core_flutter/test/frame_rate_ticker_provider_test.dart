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
  test('rejects invalid frame rates', () {
    expect(() => FrameRateTickerProvider(framesPerSecond: 0), throwsArgumentError);
    expect(() => FrameRateTickerProvider(framesPerSecond: double.nan), throwsArgumentError);
  });

  testWidgets('ticks at the requested rate without continuously scheduling frames', (tester) async {
    final key = GlobalKey<_AnimationHarnessState>();
    await tester.pumpWidget(
      TickerMode(enabled: true, child: _AnimationHarness(key: key, framesPerSecond: 30)),
    );
    await tester.pump(_vsync);
    key.currentState!.tickCount = 0;

    for (var index = 0; index < 60; index++) {
      await tester.pump(_vsync);
      expect(tester.binding.hasScheduledFrame, isFalse);
    }

    expect(key.currentState!.tickCount, inInclusiveRange(28, 32));
    expect(key.currentState!.controller.value, closeTo(0.25, 0.02));
  });

  testWidgets('rates at the display refresh rate remain vsync driven', (tester) async {
    final key = GlobalKey<_AnimationHarnessState>();
    await tester.pumpWidget(
      TickerMode(enabled: true, child: _AnimationHarness(key: key, framesPerSecond: 60)),
    );
    await tester.pump(_vsync);
    key.currentState!.tickCount = 0;

    for (var index = 0; index < 10; index++) {
      await tester.pump(_vsync);
      expect(tester.binding.hasScheduledFrame, isTrue);
    }

    expect(key.currentState!.tickCount, 10);
  });

  testWidgets('TickerMode mutes and resumes throttled controllers', (tester) async {
    final key = GlobalKey<_AnimationHarnessState>();

    Widget build({required bool enabled}) => TickerMode(
      enabled: enabled,
      child: _AnimationHarness(key: key, framesPerSecond: 30),
    );

    await tester.pumpWidget(build(enabled: false));
    expect(tester.binding.hasScheduledFrame, isFalse);
    for (var index = 0; index < 10; index++) {
      await tester.pump(_vsync);
    }
    expect(key.currentState!.controller.value, 0);

    await tester.pumpWidget(build(enabled: true));
    for (var index = 0; index < 10; index++) {
      await tester.pump(_vsync);
    }
    expect(key.currentState!.controller.value, greaterThan(0));

    await tester.pumpWidget(build(enabled: false));
    final pausedValue = key.currentState!.controller.value;
    for (var index = 0; index < 10; index++) {
      await tester.pump(_vsync);
    }
    expect(key.currentState!.controller.value, pausedValue);
    expect(tester.binding.hasScheduledFrame, isFalse);
  });

  testWidgets('changing the target rate reschedules a parked ticker', (tester) async {
    final key = GlobalKey<_AnimationHarnessState>();
    await tester.pumpWidget(
      TickerMode(enabled: true, child: _AnimationHarness(key: key, framesPerSecond: 15)),
    );
    await tester.pump(_vsync);
    key.currentState!.tickCount = 0;

    for (var index = 0; index < 60; index++) {
      await tester.pump(_vsync);
    }
    expect(key.currentState!.tickCount, inInclusiveRange(13, 17));

    key.currentState!
      ..tickCount = 0
      ..provider.framesPerSecond = 30;
    for (var index = 0; index < 60; index++) {
      await tester.pump(_vsync);
    }
    expect(key.currentState!.tickCount, inInclusiveRange(28, 32));
  });
}

class _AnimationHarness extends StatefulWidget {
  const _AnimationHarness({required this.framesPerSecond, super.key});

  final double framesPerSecond;

  @override
  State<_AnimationHarness> createState() => _AnimationHarnessState();
}

class _AnimationHarnessState extends State<_AnimationHarness> {
  late final provider = FrameRateTickerProvider(framesPerSecond: widget.framesPerSecond);
  AnimationController? _controller;
  var tickCount = 0;

  AnimationController get controller => _controller!;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    provider.bind(context);
    _controller ??= AnimationController(vsync: provider, duration: const Duration(seconds: 4))
      ..addListener(() => tickCount++)
      ..repeat();
  }

  @override
  void didUpdateWidget(covariant _AnimationHarness oldWidget) {
    super.didUpdateWidget(oldWidget);
    provider.framesPerSecond = widget.framesPerSecond;
  }

  @override
  void dispose() {
    _controller?.dispose();
    provider.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => const SizedBox.shrink();
}
