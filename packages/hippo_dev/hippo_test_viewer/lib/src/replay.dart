import 'dart:async';

import 'package:jaspr/jaspr.dart';
import 'package:jaspr/dom.dart' as dom;

import 'report_model.dart';
import 'ui.dart';

class Replay extends StatefulComponent {
  const Replay(this.scenario, {super.key});
  final Scenario scenario;
  @override
  State<Replay> createState() => _ReplayState();
}

class _ReplayState extends State<Replay> {
  int frame = 0;
  double speed = 1;
  Timer? timer;
  bool playing = false;
  List<Map<String, dynamic>> get frames => component.scenario.replay;
  void stop() {
    timer?.cancel();
    playing = false;
  }

  void schedule() {
    timer?.cancel();
    // Snapshot replay deliberately uses a readable fixed dwell, not video timing.
    timer = Timer(Duration(milliseconds: (1500 / speed).round()), () {
      if (!mounted) return;
      setState(() {
        if (frame >= frames.length - 1) {
          stop();
        } else {
          frame++;
          schedule();
        }
      });
    });
  }

  @override
  void dispose() {
    stop();
    super.dispose();
  }

  @override
  Component build(BuildContext context) => el('section', [
    if (component.scenario.video case final video?) ...[
      txt('Scenario recording', tag: 'h3'),
      el(
        'video',
        [
          el('a', [Component.text('Download recording')], attrs: {'href': video}),
        ],
        attrs: {
          'src': video,
          'controls': '',
          'preload': 'metadata',
          'aria-label': 'Scenario recording',
        },
        classes: 'scenario-video',
      ),
    ],
    el('div', [
      txt(component.scenario.frames.isEmpty ? 'Checkpoint replay' : 'Step replay', tag: 'h3'),
      txt(
        'Snapshots · 1.5 seconds per frame at 1× · not a continuous video',
        tag: 'p',
        classes: 'muted',
      ),
    ], classes: 'replay-heading'),
    if (frames.isEmpty)
      empty(
        'No replay frames',
        'Capture checkpoints or run with --record-steps to inspect the journey visually.',
      ),
    if (frames.isNotEmpty) ...[
      el('div', [
        action(
          playing ? 'Pause' : 'Play replay',
          () => setState(() {
            if (playing) {
              stop();
            } else {
              if (frame == frames.length - 1) frame = 0;
              playing = true;
              schedule();
            }
          }),
          classes: 'primary',
        ),
        action(
          'Previous frame',
          () => setState(() {
            stop();
            frame--;
          }),
          disabled: frame == 0,
        ),
        action(
          'Next frame',
          () => setState(() {
            stop();
            frame++;
          }),
          disabled: frame == frames.length - 1,
        ),
        for (final value in [0.5, 1.0, 2.0])
          action(
            '$value×',
            () => setState(() {
              speed = value;
              if (playing) schedule();
            }),
            selected: speed == value,
          ),
        txt('${frame + 1} / ${frames.length}', classes: 'muted'),
      ], classes: 'replay-controls'),
      dom.input<num>(
        type: dom.InputType.range,
        value: '$frame',
        attributes: {
          'min': '0',
          'max': '${frames.length - 1}',
          'step': '1',
          'aria-label': 'Replay frame',
        },
        onInput: (value) => setState(() {
          stop();
          frame = value.toInt();
        }),
        classes: 'scrubber',
      ),
      txt('${frames[frame]['name']}', tag: 'h4', classes: 'frame-caption'),
      el('div', [
        el(
          'img',
          [],
          attrs: {'src': artifactPath(frames[frame]['actual'])!, 'alt': '${frames[frame]['name']}'},
        ),
      ], classes: 'replay-stage'),
      el('div', [
        for (final (i, item) in frames.indexed)
          dom.button(
            [
              el(
                'img',
                [],
                attrs: {'src': artifactPath(item['actual'])!, 'alt': '', 'loading': 'lazy'},
              ),
              txt('${i + 1}. ${item['name']}'),
            ],
            classes: 'replay-thumb ${frame == i ? 'active' : ''}',
            onClick: () => setState(() {
              stop();
              frame = i;
            }),
            attributes: {'aria-pressed': '${frame == i}'},
          ),
      ], classes: 'replay-strip'),
    ],
  ], classes: 'replay');
}
