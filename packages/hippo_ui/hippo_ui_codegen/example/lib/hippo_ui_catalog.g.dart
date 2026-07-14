// GENERATED CODE - DO NOT MODIFY BY HAND.

import 'package:hippo_ui/hippo_ui.dart';
import 'package:hippo_ui_codegen_example/button_preview.dart';
import 'package:hippo_ui_codegen_example/jaspr_preview.dart';

final List<HippoUiGeneratedPreview> hippoUiGeneratedPreviews = <HippoUiGeneratedPreview>[
  HippoUiGeneratedPreview(
    id: 'package:hippo_ui_codegen_example/button_preview.dart#ButtonPreview',
    targetName: 'ButtonPreview',
    name: 'Button',
    path: 'Actions/Button',
    description: 'Primary action surface.',
    options: <HippoUiGeneratedOption>[
      HippoUiGeneratedTextOption(key: 'label', defaultValue: 'Continue'),
      HippoUiGeneratedIntegerOption(key: 'count', defaultValue: 2, min: 1, max: 5, step: 1),
    ],
    builder: (configuration) => ButtonPreview(
      label: (configuration["label"] as String?) ?? "Continue",
      count: (configuration["count"] as int?) ?? 2,
    ),
  ),
  HippoUiGeneratedPreview(
    id: 'package:hippo_ui_codegen_example/jaspr_preview.dart#JasprButtonPreview',
    targetName: 'JasprButtonPreview',
    name: 'Jaspr button',
    path: 'Actions/Button',
    description: 'Primary action surface rendered with Jaspr.',
    options: <HippoUiGeneratedOption>[
      HippoUiGeneratedTextOption(key: 'label', defaultValue: 'Continue'),
    ],
    builder: (configuration) =>
        JasprButtonPreview(label: (configuration["label"] as String?) ?? "Continue"),
  ),
];
