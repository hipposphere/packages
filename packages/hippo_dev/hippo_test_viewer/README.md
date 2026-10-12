# Hippo test viewer

A reusable Jaspr client application for `hippo_test` reports. Product repositories only depend on `hippo_test`; they do not need Jaspr, JavaScript tooling, or a report server.

- Searchable scenarios, failure filtering, named steps and authoritative runner errors.
- Golden inspection: side by side, keyboard-controlled wipe, opacity overlay, browser difference blend with brightness control, 100%/200% zoom and a shared scroll area. Images of different sizes retain their dimensions and align at the top left.
- Flutter comparator's original isolated/masked diffs remain linked separately. The browser difference view is an inspection aid; it never changes golden outcomes or thresholds.
- Checkpoint replay for existing reports; richer step replay with `--record-steps`. Playback uses a fixed 1.5-second dwell at 1×, explicitly labeled as snapshots rather than continuous video. MP4/WebM attachments use native video controls.
- Scenario/checkpoint deep links, responsive layout, native controls, keyboard focus and reduced-motion support. Replay only starts on request and stops when leaving the view.
- Versioned embedded JSON, escaped script delimiters, text-only rendering of test data, and contained relative artifact URLs. Reports work from `file://` and static hosting without fetching JSON or contacting services.

## Build and validate

From this package, using the workspace's Dart SDK:

```sh
dart tool/build.dart
dart tool/build.dart --check
dart test
dart analyze
```

This intentionally uses Jaspr's client runtime with `dart compile js`: there are no server components, annotations, generated routes or hydration islands to generate. `Jaspr.initializeApp()` initializes the standalone client. The build copies the optimized JavaScript (~180 KB uncompressed) and stylesheet into `hippo_test_core/assets/`. Commit these release assets alongside source changes. `--check` recompiles and detects stale assets; run it with the same pinned SDK used to build the committed bundle.

`hippo_test_core` copies that bundle into each run alongside `index.html`, `results.json`, `runner.log`, and PNG/video evidence. Keep the entire directory when uploading a CI artifact. Updating the viewer does not require rerunning an app test:

```sh
dart run hippo_test --report path/to/existing/run
```

Legacy reports without command/environment metadata still load and clearly identify missing reproduction data. Malformed or unsupported report versions show an error instead of a success state.

## Boundaries

This is a portable run inspector, not a hosted dashboard: it does not store history, approve baselines, provision CI, authenticate users or automatically capture device video. Artifacts may contain app data and logs; use synthetic fixtures and the same access controls as other CI artifacts.

The initial browser verification covers desktop and 390px widths, search/filtering, keyboard wipe, overlay, difference, zoom, snapshot playback, scrubbing, MP4 playback using a synthetic media fixture, and failed reports on static hosting. Browser testing across engines and hosted CI integration remain release rollout work.
