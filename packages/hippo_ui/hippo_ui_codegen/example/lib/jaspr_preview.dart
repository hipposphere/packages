import 'package:hippo_ui_jaspr/hippo_ui_jaspr.dart';

@HippoWidgetPreviewJaspr(
  name: 'Jaspr button',
  path: 'Actions/Button',
  description: 'Primary action surface rendered with Jaspr.',
)
class JasprButtonPreview {
  const JasprButtonPreview({
    @HippoWidgetPreviewField(.text(defaultValue: 'Continue')) required this.label,
  });

  final String label;
}
