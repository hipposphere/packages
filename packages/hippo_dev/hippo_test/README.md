# hippo_test

Dev-only Flutter testing utilities with named steps, deterministic rendering
configuration, golden checkpoints, and an interactive Jaspr report. Product fixtures,
app composition, and user actions stay in the consuming application.

## Write a feature test

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:hippo_test/hippo_test.dart';

void main() {
  featureTest(
    'profiles.create.mobile',
    'A profile survives reopening',
    kind: 'feature-integration',
    variant: const FeatureVariant('mobile-light'),
    run: (test) async {
      // Product-owned adapter: mount the real UI and isolate its dependencies.
      final app = await test.step('Open empty workspace', () => ProfilesScenario.open(test));
      await test.step('Create profile', () => app.createProfile('Anatomy'));
      await test.checkpoint('Created', golden: 'goldens/profile-created.png');
      await test.step('Reopen database and feature', app.reopen);
      expect(await app.profileNames(), ['Anatomy']);
    },
  );
}
```

The product adapter calls `test.mount(app)`, receives `test.variant` for its
theme/locale, and registers cleanup with `addTearDown`. The harness unmounts the
widget tree before those cleanup callbacks. Each test must have fresh mutable
fixtures. Unique IDs across all files make artifact names stable.

Use `test.waitFor(finder)` for an explicit condition and `test.settle()` for
finite transitions. Both have bounded waits and check Flutter errors. Access
`test.tester` for standard Flutter APIs; no separate assertion or finder language.
The default test timeout is 45 seconds and can be overridden with `timeout`.

`FeatureVariant` defines size, brightness, locale, and text scale. Choose a small,
explicit set of variants rather than multiplying every option. The product app
must honor the supplied theme and locale; apps that replace MediaQuery must
propagate the requested text scale. Bundled fonts load by default. Inject fixed
clocks/randomness into product dependencies where needed; the harness does not
silently replace global time or network access.

## Run and inspect

From the consuming Flutter package:

```sh
dart run hippo_test test/features/profiles/profile_journey_test.dart
dart run hippo_test test/features/profiles/profile_journey_test.dart --update-goldens
dart run hippo_test --flutter /path/to/flutter test/features
```

Additional arguments are forwarded to `flutter test`. Do not pass a different
reporter: the runner consumes Flutter's machine events. Each run produces a fresh
`build/hippo_test/<UTC timestamp>/` containing:

- `index.html` + bundled `viewer.js`/`viewer.css`: searchable scenarios, named
  steps, side-by-side/wipe/overlay/difference views, zoom, replay, and logs.
- `results.json`: final outcomes, including failures during teardown.
- `runner.log`: Flutter's test output and errors.
- Per-case JSON and PNG artifacts, including automatic failure screenshots when
  the widget tree remains renderable.

Open `index.html` directly or host the entire directory. There are no external
scripts, fonts, or services. CI can upload `build/hippo_test/` with an always-run
artifact step. The runner preserves Flutter's exit code and rejects empty or
incomplete runs. Compilation/setup failures appear even without feature records.

Golden paths are relative to the test file. Comparison uses Flutter's configured
golden comparator. With the standard local comparator the report also copies the
expected image and generates exact pixel diffs. With custom comparators only
actual images and the comparator's assertion are guaranteed. Updated goldens are
explicitly marked `updated`; review them before committing. Pin Flutter revision,
host OS, fonts, and rendering settings for golden CI.

## Scope of this prototype

Validated on macOS with Flutter widget tests and a native integration-test journey.
The current artifact transport uses
`dart:io` and the local filesystem; Flutter web and remote mobile devices need
separate artifact transport. No native-permission automation, backend provisioning,
video capture, automatic network recording, or Widgetbook catalog adapter yet.

The API builds on `testWidgets`; initializing `IntegrationTestWidgetsFlutterBinding`
allows native integration entry points. Device runs must use an appropriate
artifact path, and should normally capture evidence without enforcing widget-test
goldens. A feature host is **not** a full-app E2E test: mark its `kind` honestly.
Use `end-to-end` only when the test actually boots the application and exercises
the intended real service/platform boundary.

## Package verification

```sh
flutter test test
dart analyze
dart run tool/verify_runner.dart /path/to/flutter
```

The final command intentionally changes a golden and fails teardown, then checks
nonzero exit status and retained comparison images. Its temporary baseline and
artifacts are removed afterward.

Full-app bootstrapping and a local flashcard journey are now exercised in
MediHippo. Next proof points: a real backend sync journey; a Dicto adapter; reuse scenario data in Widgetbook; CI publication.
Extract abstractions only when these consumers demonstrate duplication.

### Full-app resources and fonts

Use `test.onCleanup(() async { ... })` for resources that must close after the
widget tree unmounts but while the widget test clock is still active. Use
`test.complete(future)` when completing that work needs virtual timers to
advance (for example Drift stream shutdown); it is bounded and preserves errors.
Use `test.waitFor(finder)` for specific ready states in apps with continuous
animations instead of waiting for every animation to settle.

Widget runs load the pinned SDK's Roboto family in addition to bundled fonts,
so implicit Material text does not become Ahem squares. Run with Flutter's
launcher (`FLUTTER_ROOT` must identify its cached material fonts). Native runs
retain their normal platform font fallback and should use separate baselines,
or evidence-only checkpoints.

## Replay and video

```sh
# Capture a screenshot after each named step, without adding scenario code.
dart run hippo_test --record-steps test/journeys
# Refresh an existing run with the current viewer; outcomes and images stay intact.
dart run hippo_test --report build/hippo_test/<run>
```

Existing runs replay their checkpoints. With `--record-steps`, the viewer instead
plays the recorded steps with play/pause, scrubber, speed and thumbnail controls.
This is explicitly labeled snapshot playback with a 1.5-second dwell at 1×, not a
continuous video or an accurate representation of test duration. Capture failures
are recorded on the step and displayed without masking the original assertion.

A device/browser runner that produces a real recording can call
`await test.attachVideo(File('recording.mp4'))` (or WebM) before cleanup. The file
is copied into the report and displayed with native video controls. Hippo does
not yet launch an OS video recorder. Captures only include the app repaint
boundary, not native dialogs or other windows. Recording is opt-in because it
adds image work and artifact storage.

The viewer lives in sibling `hippo_test_viewer`; app repos do not depend on Jaspr.
When editing it, rebuild and commit `hippo_test/assets/`, run the viewer's tests
and `tool/build.dart --check`, then inspect a successful and failed report.
