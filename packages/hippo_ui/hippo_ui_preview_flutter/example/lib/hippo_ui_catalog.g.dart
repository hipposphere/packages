// GENERATED CODE - DO NOT MODIFY BY HAND.

import 'package:flutter/widget_previews.dart';
import 'package:flutter/widgets.dart';
import 'package:hippo_ui_preview_flutter_example/button_preview.dart';
import 'package:hippo_ui_flutter/hippo_ui_flutter.dart';

final List<HippoUiGeneratedPreview>
hippoUiGeneratedPreviews = <HippoUiGeneratedPreview>[
  HippoUiGeneratedPreview(
    id: 'package:hippo_ui_preview_flutter_example/button_preview.dart#PreviewButton',
    targetName: 'PreviewButton',
    name: 'Demo button',
    path: 'Components/Button',
    description:
        'A configurable button preview rendered from the generated catalog.',
    options: <HippoUiGeneratedOption>[
      HippoUiGeneratedTextOption(
        key: 'label',
        label: 'Label',
        defaultValue: 'Continue',
      ),
      HippoUiGeneratedIntegerOption(
        key: 'count',
        label: 'Count',
        defaultValue: 2,
        min: 0,
        max: 8,
        step: 1,
      ),
      HippoUiGeneratedBooleanOption(
        key: 'prominent',
        label: 'Prominent',
        defaultValue: true,
      ),
      HippoUiGeneratedTextOption(
        key: 'icon',
        label: 'Icon',
        defaultValue: '{"codePoint":57686,"fontFamily":"MaterialIcons"}',
        values: <HippoUiGeneratedOptionValue<String>>[
          HippoUiGeneratedOptionValue(
            value: '{"codePoint":57686,"fontFamily":"MaterialIcons"}',
            label: 'Check',
          ),
          HippoUiGeneratedOptionValue(
            value: '{"codePoint":57706,"fontFamily":"MaterialIcons"}',
            label: 'Close',
          ),
        ],
      ),
    ],
    builder: (configuration) => PreviewButton(
      label: (configuration["label"] as String?) ?? "Continue",
      count: (configuration["count"] as int?) ?? 2,
      prominent: (configuration["prominent"] as bool?) ?? true,
      icon: switch ((configuration["icon"] as String?) ??
          "{\"codePoint\":57686,\"fontFamily\":\"MaterialIcons\"}") {
        "{\"codePoint\":57686,\"fontFamily\":\"MaterialIcons\"}" =>
          const IconData(57686, fontFamily: 'MaterialIcons'),
        "{\"codePoint\":57706,\"fontFamily\":\"MaterialIcons\"}" =>
          const IconData(57706, fontFamily: 'MaterialIcons'),
        _ => const IconData(57686, fontFamily: 'MaterialIcons'),
      },
    ),
  ),
  HippoUiGeneratedPreview(
    id: 'package:hippo_ui_preview_flutter_example/button_preview.dart#PreviewStatusCard',
    targetName: 'PreviewStatusCard',
    name: 'Status card',
    path: 'Components/Card',
    description:
        'A compact status card preview with configurable tone and value.',
    options: <HippoUiGeneratedOption>[
      HippoUiGeneratedTextOption(
        key: 'title',
        label: 'Title',
        defaultValue: 'Pipeline health',
      ),
      HippoUiGeneratedTextOption(
        key: 'value',
        label: 'Value',
        defaultValue: '98%',
      ),
      HippoUiGeneratedBooleanOption(
        key: 'warning',
        label: 'Warning',
        defaultValue: false,
      ),
      HippoUiGeneratedTextOption(
        key: 'alignment',
        label: 'Alignment',
        defaultValue: 'center',
        values: <HippoUiGeneratedOptionValue<String>>[
          HippoUiGeneratedOptionValue(value: 'topLeft', label: 'Top left'),
          HippoUiGeneratedOptionValue(value: 'topCenter', label: 'Top center'),
          HippoUiGeneratedOptionValue(value: 'topRight', label: 'Top right'),
          HippoUiGeneratedOptionValue(
            value: 'centerLeft',
            label: 'Center left',
          ),
          HippoUiGeneratedOptionValue(value: 'center', label: 'Center'),
          HippoUiGeneratedOptionValue(
            value: 'centerRight',
            label: 'Center right',
          ),
          HippoUiGeneratedOptionValue(
            value: 'bottomLeft',
            label: 'Bottom left',
          ),
          HippoUiGeneratedOptionValue(
            value: 'bottomCenter',
            label: 'Bottom center',
          ),
          HippoUiGeneratedOptionValue(
            value: 'bottomRight',
            label: 'Bottom right',
          ),
        ],
      ),
      HippoUiGeneratedEnumOption(
        key: 'mainAxisAlignment',
        label: 'Layout',
        defaultValue: 'start',
        enumType: 'MainAxisAlignment',
        values: <HippoUiGeneratedOptionValue<String>>[
          HippoUiGeneratedOptionValue(value: 'start', label: 'Start'),
          HippoUiGeneratedOptionValue(value: 'center', label: 'Center'),
          HippoUiGeneratedOptionValue(value: 'end', label: 'End'),
          HippoUiGeneratedOptionValue(
            value: 'spaceBetween',
            label: 'Space between',
          ),
        ],
      ),
    ],
    builder: (configuration) => PreviewStatusCard(
      title: (configuration["title"] as String?) ?? "Pipeline health",
      value: (configuration["value"] as String?) ?? "98%",
      warning: (configuration["warning"] as bool?) ?? false,
      alignment: const HippoUiAlignmentConverter().convert(
        configuration["alignment"],
      ),
      mainAxisAlignment: MainAxisAlignment.values.byName(
        (configuration["mainAxisAlignment"] as String?) ?? "start",
      ),
    ),
  ),
];
@Preview(group: 'Components/Button', name: 'Demo button')
Widget hippoUiFlutterPreviewPreviewButton1ewqivl() {
  final configuration = <String, Object?>{
    'label': 'Continue',
    'count': 2,
    'prominent': true,
    'icon': '{"codePoint":57686,"fontFamily":"MaterialIcons"}',
  };
  return PreviewButton(
    label: (configuration["label"] as String?) ?? "Continue",
    count: (configuration["count"] as int?) ?? 2,
    prominent: (configuration["prominent"] as bool?) ?? true,
    icon: switch ((configuration["icon"] as String?) ??
        "{\"codePoint\":57686,\"fontFamily\":\"MaterialIcons\"}") {
      "{\"codePoint\":57686,\"fontFamily\":\"MaterialIcons\"}" =>
        const IconData(57686, fontFamily: 'MaterialIcons'),
      "{\"codePoint\":57706,\"fontFamily\":\"MaterialIcons\"}" =>
        const IconData(57706, fontFamily: 'MaterialIcons'),
      _ => const IconData(57686, fontFamily: 'MaterialIcons'),
    },
  );
}

@Preview(group: 'Components/Card', name: 'Status card')
Widget hippoUiFlutterPreviewPreviewStatusCard12q22o9() {
  final configuration = <String, Object?>{
    'title': 'Pipeline health',
    'value': '98%',
    'warning': false,
    'alignment': 'center',
    'mainAxisAlignment': 'start',
  };
  return PreviewStatusCard(
    title: (configuration["title"] as String?) ?? "Pipeline health",
    value: (configuration["value"] as String?) ?? "98%",
    warning: (configuration["warning"] as bool?) ?? false,
    alignment: const HippoUiAlignmentConverter().convert(
      configuration["alignment"],
    ),
    mainAxisAlignment: MainAxisAlignment.values.byName(
      (configuration["mainAxisAlignment"] as String?) ?? "start",
    ),
  );
}
