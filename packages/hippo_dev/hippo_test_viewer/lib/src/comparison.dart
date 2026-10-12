import 'package:jaspr/jaspr.dart';
import 'package:jaspr/dom.dart' as dom;
import 'package:web/web.dart' as web;

import 'report_model.dart';
import 'ui.dart';

class Comparison extends StatefulComponent {
  const Comparison(this.shot, {super.key});
  final Map<String, dynamic> shot;
  @override
  State<Comparison> createState() => _ComparisonState();
}

class _ComparisonState extends State<Comparison> {
  String mode = 'Side by side', zoom = 'Fit';
  double amount = 50, gain = 4;
  final sizes = <String, (int, int)>{};
  final broken = <String>{};
  Map<String, dynamic> get shot => component.shot;
  String? path(String key) => artifactPath(shot[key]);
  int get width => sizes.values.fold(1, (v, s) => v > s.$1 ? v : s.$1);
  int get height => sizes.values.fold(1, (v, s) => v > s.$2 ? v : s.$2);
  Component picture(String key) => path(key) == null
      ? empty('No $key image', 'This artifact was not produced by the runner.')
      : el('div', [
          dom.img(
            src: path(key)!,
            alt: '$key — ${shot['name']}',
            attributes: {
              'style': sizes[key] == null
                  ? 'width:100%;position:relative'
                  : 'width:${sizes[key]!.$1 / width * 100}%;height:auto',
            },
            events: {
              'load': (event) {
                final img = event.target as web.HTMLImageElement;
                final next = (img.naturalWidth, img.naturalHeight);
                if (sizes[key] != next) setState(() => sizes[key] = next);
              },
              'error': (_) => setState(() => broken.add(key)),
            },
          ),
          if (broken.contains(key))
            empty(
              'Image unavailable',
              'The $key artifact is missing or unreadable. Copy the complete report folder.',
            ),
        ], classes: 'image-plane');
  Component canvas(String key) => el(
    'div',
    [picture(key)],
    classes: 'canvas',
    attrs: {'style': 'aspect-ratio:$width / $height'},
  );
  @override
  Component build(BuildContext context) {
    final paired = path('expected') != null && path('actual') != null;
    final options = [
      if (paired) ...['Side by side', 'Wipe', 'Overlay', 'Difference'],
      'Actual',
      if (path('expected') != null) 'Expected',
    ];
    final view = options.contains(mode) ? mode : 'Actual';
    final mismatch =
        sizes['actual'] != null &&
        sizes['expected'] != null &&
        sizes['actual'] != sizes['expected'];
    final diff = shot['diffPercent'];
    return el('div', [
      el('div', [
        el('div', [
          txt('${shot['name']}', tag: 'h3'),
          el('div', [
            badge('${shot['status']}'),
            if (diff is num)
              txt('${(diff * 100).toStringAsFixed(3)}% pixels changed', classes: 'muted'),
            if (shot['status'] == 'updated')
              txt('Previous baseline vs newly captured image', classes: 'warning'),
          ], classes: 'metadata'),
        ]),
        el('div', [
          for (final key in ['expected', 'actual'])
            if (path(key) != null)
              el(
                'a',
                [Component.text('Open $key ↗')],
                attrs: {'href': path(key)!, 'target': '_blank', 'rel': 'noopener'},
              ),
        ], classes: 'artifact-links'),
      ], classes: 'comparison-heading'),
      el('div', [
        el(
          'div',
          [
            for (final option in options)
              action(option, () => setState(() => mode = option), selected: view == option),
          ],
          classes: 'segmented',
          attrs: {'aria-label': 'Comparison mode'},
        ),
        el(
          'div',
          [
            for (final value in ['Fit', '100%', '200%'])
              action(value, () => setState(() => zoom = value), selected: zoom == value),
          ],
          classes: 'segmented zoom',
          attrs: {'aria-label': 'Image zoom'},
        ),
      ], classes: 'comparison-toolbar'),
      if (view == 'Wipe' || view == 'Overlay')
        el('label', [
          txt(view == 'Wipe' ? 'Wipe position' : 'Actual opacity'),
          dom.input<num>(
            type: dom.InputType.range,
            value: '$amount',
            attributes: {
              'min': '0',
              'max': '100',
              'step': '1',
              'aria-label': view == 'Wipe' ? 'Wipe position' : 'Actual opacity',
            },
            onInput: (v) => setState(() => amount = v.toDouble()),
          ),
          txt('${amount.round()}%'),
        ], classes: 'slider-row'),
      if (view == 'Difference')
        el('label', [
          txt('Difference brightness'),
          dom.input<num>(
            type: dom.InputType.range,
            value: '$gain',
            attributes: {
              'min': '1',
              'max': '16',
              'step': '1',
              'aria-label': 'Difference brightness',
            },
            onInput: (value) => setState(() => gain = value.toDouble()),
          ),
          txt('${gain.round()}× · display only'),
        ], classes: 'slider-row'),
      if (mismatch)
        txt(
          'Image dimensions differ. Both are aligned at the top left at the same scale.',
          tag: 'p',
          classes: 'dimension-warning',
        ),
      el(
        'div',
        [
          el(
            'div',
            [
              if (view == 'Side by side')
                for (final key in ['expected', 'actual'])
                  el('figure', [
                    txt(key == 'expected' ? 'EXPECTED' : 'ACTUAL', tag: 'figcaption'),
                    canvas(key),
                  ]),
              if (view == 'Actual' || view == 'Expected')
                el('figure', [
                  txt(view.toUpperCase(), tag: 'figcaption'),
                  canvas(view.toLowerCase()),
                ]),
              if (view == 'Wipe' || view == 'Overlay' || view == 'Difference')
                el('figure', [
                  txt(
                    view == 'Difference'
                        ? 'PIXEL DIFFERENCE · BRIGHT AREAS INDICATE CHANGE'
                        : view == 'Wipe'
                        ? 'ACTUAL ← WIPE → EXPECTED'
                        : 'EXPECTED + ACTUAL',
                    tag: 'figcaption',
                  ),
                  el(
                    'div',
                    [
                      picture('expected'),
                      el(
                        'div',
                        [picture('actual')],
                        classes: 'comparison-layer',
                        attrs: {
                          'style': view == 'Wipe'
                              ? 'clip-path:inset(0 ${100 - amount}% 0 0)'
                              : view == 'Overlay'
                              ? 'opacity:${amount / 100}'
                              : 'mix-blend-mode:difference',
                        },
                      ),
                      if (view == 'Wipe')
                        el('div', [], classes: 'wipe-handle', attrs: {'style': 'left:$amount%'}),
                    ],
                    classes: 'canvas',
                    attrs: {
                      'style':
                          'aspect-ratio:$width / $height;filter:brightness(${view == 'Difference' ? gain : 1})',
                    },
                  ),
                ]),
            ],
            classes: 'compare-images ${view == 'Side by side' ? 'paired' : ''}',
            attrs: {
              'style': zoom == 'Fit'
                  ? 'max-width:${width * (view == 'Side by side' ? 2 : 1) + (view == 'Side by side' ? 24 : 0)}px'
                  : 'width:${width * (zoom == '200%' ? 2 : 1) * (view == 'Side by side' ? 2 : 1) + (view == 'Side by side' ? 24 : 0)}px;max-width:none',
            },
          ),
        ],
        classes: 'stage',
        attrs: {'tabindex': '0', 'aria-label': 'Image comparison; scroll to pan when zoomed'},
      ),
      el('div', [
        txt(
          sizes['expected'] == null
              ? 'Expected not measured'
              : 'Expected ${sizes['expected']!.$1} × ${sizes['expected']!.$2}',
        ),
        txt(
          sizes['actual'] == null
              ? 'Actual not measured'
              : 'Actual ${sizes['actual']!.$1} × ${sizes['actual']!.$2}',
        ),
        for (final key in ['isolatedDiff', 'maskedDiff'])
          if (path(key) != null)
            el(
              'a',
              [Component.text(key == 'isolatedDiff' ? 'Comparator diff ↗' : 'Masked diff ↗')],
              attrs: {'href': path(key)!, 'target': '_blank', 'rel': 'noopener'},
            ),
      ], classes: 'image-meta'),
      if (shot['error'] != null) txt('${shot['error']}', tag: 'pre', classes: 'errors'),
    ], classes: 'comparison');
  }
}
