import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hippo_test/hippo_test.dart';

void main() {
  featureTest(
    'harness.wait',
    'Waits for a delayed state without waiting for all animations',
    loadFonts: false,
    run: (test) async {
      await test.mount(const Directionality(textDirection: TextDirection.ltr, child: _Delayed()));
      await test.waitFor(find.text('Ready'));
      expect(find.text('Ready'), findsOneWidget);
      Object? timeout;
      try {
        await test.waitFor(find.text('Missing'), timeout: const Duration(milliseconds: 100));
      } catch (error) {
        timeout = error;
      }
      expect(
        timeout,
        isA<TestFailure>().having((error) => error.message, 'message', contains('Missing')),
      );
    },
  );

  featureTest(
    'harness.configuration',
    'Applies viewport, text scale and brightness',
    loadFonts: false,
    variant: const FeatureVariant(
      'accessible-desktop',
      size: Size(900, 700),
      brightness: Brightness.dark,
      textScale: 1.5,
    ),
    run: (test) async {
      late MediaQueryData media;
      await test.mount(
        Builder(
          builder: (context) {
            media = MediaQuery.of(context);
            return const SizedBox();
          },
        ),
      );
      expect(media.size, const Size(900, 700));
      expect(media.platformBrightness, Brightness.dark);
      expect(media.textScaler.scale(10), 15);
      expect(test.tester.view.physicalSize, const Size(900, 700));
    },
  );
  featureTest(
    'harness.resource-lifecycle',
    'Completes clock-dependent work and cleans up after unmount',
    loadFonts: false,
    run: (test) async {
      var cleaned = false;
      addTearDown(() => expect(cleaned, isTrue));
      await test.mount(
        const Directionality(textDirection: TextDirection.ltr, child: Text('Mounted')),
      );
      expect(await test.complete(Future.delayed(const Duration(milliseconds: 100), () => 42)), 42);
      Object? failure;
      try {
        await test.complete(Future<int>.error(StateError('original failure')));
      } catch (error) {
        failure = error;
      }
      expect(failure, isA<StateError>());
      Object? timeout;
      try {
        await test.complete(Completer<void>().future, timeout: const Duration(milliseconds: 100));
      } catch (error) {
        timeout = error;
      }
      expect(timeout, isA<TestFailure>());
      test.onCleanup(() async {
        expect(find.text('Mounted'), findsNothing);
        await test.complete(Future<void>.delayed(const Duration(milliseconds: 100)));
        cleaned = true;
      });
    },
  );
}

class _Delayed extends StatefulWidget {
  const _Delayed();
  @override
  State<_Delayed> createState() => _DelayedState();
}

class _DelayedState extends State<_Delayed> {
  bool ready = false;
  @override
  void initState() {
    super.initState();
    Future<void>.delayed(const Duration(milliseconds: 150), () {
      if (mounted) setState(() => ready = true);
    });
  }

  @override
  Widget build(BuildContext context) => Text(ready ? 'Ready' : 'Loading');
}
