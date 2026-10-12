import 'package:jaspr/jaspr.dart';
import 'package:jaspr/dom.dart' as dom;

Component el(String tag, List<Component> children, {String? classes, Map<String, String>? attrs}) =>
    Component.element(tag: tag, classes: classes, attributes: attrs, children: children);
Component txt(String value, {String tag = 'span', String? classes}) =>
    el(tag, [Component.text(value)], classes: classes);
Component action(
  String label,
  void Function() onClick, {
  bool selected = false,
  bool disabled = false,
  String? classes,
}) => dom.button(
  [Component.text(label)],
  onClick: onClick,
  disabled: disabled,
  classes: '${classes ?? ''} ${selected ? 'selected' : ''}',
  attributes: {'type': 'button', 'aria-pressed': '$selected'},
);
Component badge(String status) => txt(
  status,
  classes:
      'badge ${['passed', 'failed', 'updated', 'captured', 'skipped', 'incomplete'].contains(status) ? status : 'incomplete'}',
);
Component empty(String title, String detail) =>
    el('div', [txt(title, tag: 'h3'), txt(detail, tag: 'p')], classes: 'empty');
