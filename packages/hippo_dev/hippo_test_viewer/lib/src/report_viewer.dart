import 'package:jaspr/jaspr.dart';
import 'package:jaspr/dom.dart' as dom;
import 'package:web/web.dart' as web;

import 'comparison.dart';
import 'replay.dart';
import 'report_model.dart';
import 'ui.dart';

class ReportViewer extends StatefulComponent {
  const ReportViewer(this.run, {super.key});
  final TestRun run;
  @override
  State<ReportViewer> createState() => _ReportViewerState();
}

class _ReportViewerState extends State<ReportViewer> {
  int selected = 0, checkpoint = 0;
  String query = '', filter = 'All', tab = 'Goldens';
  TestRun get run => component.run;
  @override
  void initState() {
    super.initState();
    final hash = Uri.splitQueryString(web.window.location.hash.replaceFirst('#', ''));
    final fromLink = run.cases.indexWhere((c) => c.id == hash['scenario']);
    selected = fromLink >= 0 ? fromLink : run.cases.indexWhere((c) => c.status == 'failed');
    if (selected < 0) selected = 0;
    if (run.cases.isNotEmpty) {
      final c = run.cases[selected];
      checkpoint =
          (int.tryParse(hash['checkpoint'] ?? '') ??
                  c.shots.indexWhere((s) => s['status'] == 'failed'))
              .clamp(0, c.shots.isEmpty ? 0 : c.shots.length - 1);
    }
  }

  void choose(int index) => setState(() {
    selected = index;
    checkpoint = 0;
    final c = run.cases[index];
    tab = c.shots.isEmpty ? 'Steps' : 'Goldens';
    final failed = c.shots.indexWhere((s) => s['status'] == 'failed');
    if (failed >= 0) checkpoint = failed;
    updateLink();
  });
  void updateLink() {
    if (run.cases.isEmpty) return;
    final hash = Uri(
      queryParameters: {'scenario': run.cases[selected].id, 'checkpoint': '$checkpoint'},
    ).query;
    web.window.history.replaceState(null, '', '#$hash');
  }

  @override
  Component build(BuildContext context) {
    final visible = run.cases.indexed
        .where(
          (entry) =>
              entry.$2.matches(query) &&
              (filter == 'All' ||
                  (filter == 'Needs attention'
                      ? entry.$2.status != 'passed' && entry.$2.status != 'skipped'
                      : entry.$2.status == 'passed')),
        )
        .toList();
    final current = run.cases.isEmpty ? null : run.cases[selected];
    return el('div', [
      el(
        'a',
        [Component.text('Skip to scenario')],
        classes: 'skip-link',
        attrs: {'href': '#scenario'},
      ),
      el('aside', [
        el('div', [
          txt('h', classes: 'brand-mark'),
          el('div', [txt('hippo test', tag: 'strong'), txt('RUN INSPECTOR', tag: 'small')]),
        ], classes: 'brand'),
        el('div', [
          txt(run.exitCode == 0 ? 'Run passed' : 'Run failed', tag: 'h1'),
          txt('${run.passed} of ${run.cases.length} scenarios passed', tag: 'p'),
          el(
            'div',
            [],
            classes: 'health-track',
            attrs: {
              'style': '--progress:${run.cases.isEmpty ? 0 : 100 * run.passed / run.cases.length}%',
            },
          ),
        ], classes: 'run-summary'),
        dom.input<String>(
          type: dom.InputType.search,
          value: query,
          onInput: (value) => setState(() => query = value),
          attributes: {'aria-label': 'Search scenarios', 'placeholder': 'Search scenarios…'},
          classes: 'search',
        ),
        el('div', [
          for (final f in ['All', 'Needs attention', 'Passed'])
            action(f, () => setState(() => filter = f), selected: filter == f),
        ], classes: 'filters'),
        txt('SCENARIOS · ${visible.length}', classes: 'section-label'),
        el(
          'nav',
          [
            for (final (index, c) in visible)
              dom.button(
                [
                  el('div', [badge(c.status), txt(c.elapsed, classes: 'muted')], classes: 'spread'),
                  txt(c.title, tag: 'strong'),
                  txt(c.variant, tag: 'small'),
                ],
                classes: 'scenario-link ${selected == index ? 'active' : ''}',
                onClick: () => choose(index),
                attributes: {'aria-current': selected == index ? 'true' : 'false'},
              ),
            if (visible.isEmpty) empty('No matching scenarios', 'Try another search or filter.'),
          ],
          attrs: {'aria-label': 'Scenarios'},
        ),
        el('footer', [
          txt('Portable report', tag: 'strong'),
          txt('Jaspr · local artifacts · no services', tag: 'small'),
          el(
            'a',
            [Component.text('Download results ↗')],
            attrs: {'href': 'results.json', 'download': ''},
          ),
        ], classes: 'sidebar-footer'),
      ], classes: 'sidebar'),
      el('main', [
        el('header', [
          txt('TEST RUN / INSPECTION', classes: 'eyebrow'),
          el('div', [
            txt('${run.cases.length} scenarios'),
            txt('${run.goldenCount} goldens'),
            if (run.updatedCount > 0)
              txt('${run.updatedCount} baselines updated', classes: 'warning'),
            txt('Exit ${run.exitCode}'),
          ], classes: 'run-stats'),
        ], classes: 'topbar'),
        if (run.exitCode != 0)
          el('div', [
            txt(
              'This run failed. Review scenario errors and runner output, including setup and teardown failures.',
            ),
          ], classes: 'run-alert'),
        if (current == null)
          empty(
            'No scenarios recorded',
            'Open Run details below to inspect setup or compilation output.',
          ),
        if (current != null) ...[
          el(
            'section',
            [
              el('div', [
                badge(current.status),
                txt(current.variant),
                txt('${current.data['viewport'] ?? ''}'),
                txt(current.elapsed),
                txt('${current.data['kind'] ?? ''}'),
              ], classes: 'metadata'),
              txt(current.title, tag: 'h2'),
              txt(current.id, tag: 'p', classes: 'scenario-id'),
            ],
            classes: 'scenario-heading',
            attrs: {'id': 'scenario', 'tabindex': '-1'},
          ),
          el(
            'div',
            [
              for (final name in ['Goldens', 'Replay', 'Steps'])
                action(
                  '$name${name == 'Goldens'
                      ? ' (${current.shots.length})'
                      : name == 'Steps'
                      ? ' (${current.steps.length})'
                      : ''}',
                  () => setState(() => tab = name),
                  selected: tab == name,
                ),
            ],
            classes: 'view-tabs',
            attrs: {'aria-label': 'Scenario views'},
          ),
          if (tab == 'Goldens')
            current.shots.isEmpty
                ? empty(
                    'No visual checkpoints',
                    'Steps and runner output are still available for this scenario.',
                  )
                : el('section', [
                    el(
                      'div',
                      [
                        for (final (i, shot) in current.shots.indexed)
                          dom.button(
                            [
                              if (artifactPath(shot['actual']) case final path?)
                                el('img', [], attrs: {'src': path, 'alt': '', 'loading': 'lazy'}),
                              el('div', [
                                txt('${i + 1}'.padLeft(2, '0'), classes: 'muted'),
                                txt('${shot['name']}', tag: 'strong'),
                                badge('${shot['status']}'),
                              ]),
                            ],
                            classes: 'checkpoint ${i == checkpoint ? 'active' : ''}',
                            onClick: () => setState(() {
                              checkpoint = i;
                              updateLink();
                            }),
                            attributes: {'aria-pressed': '${i == checkpoint}'},
                          ),
                      ],
                      classes: 'filmstrip',
                      attrs: {'aria-label': 'Visual checkpoints'},
                    ),
                    Comparison(
                      current.shots[checkpoint],
                      key: ValueKey('${current.id}-$checkpoint'),
                    ),
                  ]),
          if (tab == 'Replay') Replay(current, key: ValueKey(current.id)),
          if (tab == 'Steps')
            el('ol', [
              for (final (i, step) in current.steps.indexed)
                el('li', [
                  txt('${i + 1}'.padLeft(2, '0'), classes: 'step-number'),
                  el('div', [
                    txt('${step['name']}', tag: 'strong'),
                    if (step['captureError'] != null)
                      txt(
                        'Replay capture unavailable: ${step['captureError']}',
                        tag: 'p',
                        classes: 'warning',
                      ),
                    if (step['error'] != null) txt('${step['error']}', tag: 'pre'),
                  ]),
                  badge('${step['status']}'),
                  txt(duration(step['durationMs']), classes: 'muted'),
                ]),
            ], classes: 'steps'),
          if (current.errors.isNotEmpty)
            el(
              'details',
              [txt('Scenario errors', tag: 'summary'), txt(current.errors, tag: 'pre')],
              classes: 'errors',
              attrs: {'open': ''},
            ),
        ],
        el('details', [
          txt('Run details & runner output', tag: 'summary'),
          txt('Reproduce', tag: 'h3'),
          txt(
            run.command.isEmpty ? 'Command was not recorded in this legacy report.' : run.command,
            tag: 'pre',
          ),
          txt(run.environment, tag: 'pre'),
          el(
            'a',
            [Component.text('Download runner log ↗')],
            attrs: {'href': 'runner.log', 'download': ''},
          ),
          txt(run.runnerLog, tag: 'pre'),
        ], classes: 'run-details'),
      ], classes: 'workspace'),
    ], classes: 'app-shell');
  }
}
