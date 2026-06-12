import 'package:hippo_ui/hippo_ui.dart';

@HippoWidgetPreview(name: 'Button', path: 'Actions/Button', description: 'Primary action surface.')
class ButtonPreview {
  const ButtonPreview({
    @HippoWidgetPreviewField(.text(defaultValue: 'Continue')) required this.label,
    @HippoWidgetPreviewField(.integerRange(defaultValue: 2, min: 1, max: 5)) required this.count,
  });

  final String label;

  final int count;
}
