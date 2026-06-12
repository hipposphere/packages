/*
// ---------------------------------------------------------------------------
// Copyright (c) 2025 HippoSphere UG (haftungsbeschränkt). All rights reserved.
// Use, copying, modification, or distribution of this software is prohibited
// without express written permission from Hipposphere UG.
//
// SPDX-License-Identifier: LicenseRef-Hipposphere-Proprietary
// ---------------------------------------------------------------------------
*/

import 'package:flutter/material.dart';
import 'package:hippo_core_flutter/hippo_core_flutter.dart';
import 'package:hippo_ui/hippo_ui.dart';
import 'package:hippo_ui_preview_flutter/hippo_ui_preview_flutter.dart';

import 'environment_builder.dart';
import 'hippo_ui_catalog.g.dart';

final hippoUiPreviewCatalog = HippoUiCatalog(hippoUiGeneratedPreviews);

void main() {
  runApp(const HippoUiPreviewFlutterExample());
}

final class HippoUiPreviewFlutterExample extends StatelessWidget {
  const HippoUiPreviewFlutterExample({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xff236b5f))),
      home: const PreviewExamplePage(),
    );
  }
}

final class PreviewExamplePage extends StatefulWidget {
  const PreviewExamplePage({super.key});

  @override
  State<PreviewExamplePage> createState() => _PreviewExamplePageState();
}

final class _PreviewExamplePageState extends State<PreviewExamplePage> {
  late HippoUiGeneratedPreview _selectedPreview;
  late HippoUiPlaygroundController _playgroundController;
  late HippoUiPreviewEnvironmentController _environmentController;

  @override
  void initState() {
    super.initState();
    _selectedPreview = hippoUiPreviewCatalog.sortedPreviews().first;
    _playgroundController = HippoUiPlaygroundController(previewDefinition: _selectedPreview);
    _environmentController = HippoUiPreviewEnvironmentController(
      keyValueStore: MockKeyValueStore(),
      addons: <HippoUiPreviewAddon<HippoUiPreviewAddonState>>[
        const ThemeTypeAddon(),
        const HitboxAddon(),
        const WidgetOutlineAddon(),
        LocaleAddon(
          defaultLocale: const Locale('en'),
          supportedLocales: const <Locale>[Locale('en'), Locale('de'), Locale('fr')],
        ),
        const GridAddon(),
        const ZoomAddon(),
        const AlignmentAddon(),
        const ViewportAddon(),
      ],
    );
  }

  @override
  void dispose() {
    _playgroundController.dispose();
    _environmentController.dispose();
    super.dispose();
  }

  void _selectPreview(HippoUiGeneratedPreview preview) {
    setState(() {
      _selectedPreview = preview;
      _playgroundController.loadPreviewDefinition(preview);
    });
  }

  @override
  Widget build(BuildContext context) {
    return PreviewEnvironmentBuilder(
      environmentController: _environmentController,
      builder: (context, environment) {
        return Scaffold(
          appBar: AppBar(title: const Text('Hippo UI Preview Flutter')),
          body: Row(
            children: <Widget>[
              SizedBox(
                width: 280,
                child: CatalogPanel(
                  previews: hippoUiPreviewCatalog.sortedPreviews(),
                  selectedPreview: _selectedPreview,
                  onSelectPreview: _selectPreview,
                ),
              ),
              const VerticalDivider(width: 1),
              Expanded(
                child: PlaygroundPanel(
                  playgroundController: _playgroundController,
                  environment: environment,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

final class CatalogPanel extends StatelessWidget {
  const CatalogPanel({
    required this.previews,
    required this.selectedPreview,
    required this.onSelectPreview,
    super.key,
  });

  final List<HippoUiGeneratedPreview> previews;

  final HippoUiGeneratedPreview selectedPreview;

  final ValueChanged<HippoUiGeneratedPreview> onSelectPreview;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(12),
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
          child: Text('Generated catalog', style: Theme.of(context).textTheme.titleMedium),
        ),
        for (final preview in previews)
          ListTile(
            selected: preview.targetName == selectedPreview.targetName,
            title: Text(preview.name),
            subtitle: Text(preview.path),
            onTap: () => onSelectPreview(preview),
          ),
      ],
    );
  }
}

final class PlaygroundPanel extends StatelessWidget {
  const PlaygroundPanel({required this.playgroundController, required this.environment, super.key});

  final HippoUiPlaygroundController playgroundController;

  final PreviewEnvironment environment;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Expanded(
          child: HippoUiPlaygroundFlutterBuilder(
            playgroundController: playgroundController,
            builder: (context, state, configuration) {
              return environment.wrapPreview((context) => _buildPreviewFor(state, configuration));
            },
          ),
        ),
        const VerticalDivider(width: 1),
        SizedBox(
          width: 320,
          child: HippoUiPlaygroundFlutterBuilder(
            playgroundController: playgroundController,
            builder: (context, state, configuration) {
              return OptionPanel(
                playgroundState: state,
                configuration: configuration,
                environment: environment,
                onConfigurationChanged: playgroundController.updateConfigurationValue,
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildPreviewFor(
    HippoUiPlaygroundState state,
    HippoUiPlaygroundConfiguration configuration,
  ) {
    final preview = state.previewDefinition.build(configuration.values);
    if (preview is Widget) {
      return preview;
    }

    return const Center(child: Text('No renderer registered for this preview.'));
  }
}

final class OptionPanel extends StatelessWidget {
  const OptionPanel({
    required this.playgroundState,
    required this.configuration,
    required this.environment,
    required this.onConfigurationChanged,
    super.key,
  });

  final HippoUiPlaygroundState playgroundState;

  final HippoUiPlaygroundConfiguration configuration;

  final PreviewEnvironment environment;

  final void Function(String optionKey, Object? value) onConfigurationChanged;

  @override
  Widget build(BuildContext context) {
    final preview = playgroundState.previewDefinition;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: <Widget>[
        Text(preview.name, style: Theme.of(context).textTheme.titleLarge),
        if (preview.description != null) ...<Widget>[
          const SizedBox(height: 6),
          Text(preview.description!),
        ],
        const SizedBox(height: 24),
        Text('Addons', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 12),
        _AddonControlPanel(environment: environment),
        const SizedBox(height: 24),
        Text('Preview options', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 12),
        for (final option in preview.options)
          Padding(
            padding: const EdgeInsets.only(bottom: 18),
            child: _OptionControl(
              option: option,
              value: configuration.valueFor(option.key),
              onChanged: (value) => onConfigurationChanged(option.key, value),
            ),
          ),
      ],
    );
  }
}

final class _AddonControlPanel extends StatelessWidget {
  const _AddonControlPanel({required this.environment});

  final PreviewEnvironment environment;

  @override
  Widget build(BuildContext context) {
    final themeTypeState = environment.themeTypeState;
    final hitboxesEnabled = HitboxAddon.enabledFromState(environment.hitboxState);
    final widgetOutlinesEnabled = WidgetOutlineAddon.enabledFromState(
      environment.widgetOutlineState,
    );
    final localeAddon = environment.localeAddon;
    final gridState = environment.gridState;
    final zoomState = environment.zoomState;
    final alignmentState = environment.alignmentState;
    final viewportState = environment.viewportState;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        DropdownButtonFormField<ThemeType>(
          initialValue: themeTypeState.themeType,
          decoration: const InputDecoration(labelText: 'Theme type', border: OutlineInputBorder()),
          items: const [
            .new(value: .system, child: Text('System')),
            .new(value: .light, child: Text('Light')),
            .new(value: .dark, child: Text('Dark')),
          ],
          onChanged: (themeType) {
            if (themeType != null) {
              environment.updateThemeType(themeType);
            }
          },
        ),
        const SizedBox(height: 18),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: const Text('Hitboxes'),
          value: hitboxesEnabled,
          onChanged: environment.updateHitboxesEnabled,
        ),
        const SizedBox(height: 18),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: const Text('Widget outlines'),
          value: widgetOutlinesEnabled,
          onChanged: environment.updateWidgetOutlinesEnabled,
        ),
        const SizedBox(height: 18),
        DropdownButtonFormField<Locale>(
          initialValue: environment.locale,
          decoration: const InputDecoration(labelText: 'Locale', border: OutlineInputBorder()),
          items: [
            for (final locale in localeAddon.supportedLocales)
              .new(value: locale, child: Text(LocaleAddon.localeLabel(locale))),
          ],
          onChanged: (locale) {
            if (locale != null) {
              environment.updateLocale(locale);
            }
          },
        ),
        const SizedBox(height: 18),
        DropdownButtonFormField<Alignment>(
          initialValue: alignmentState.alignment,
          decoration: const InputDecoration(labelText: 'Alignment', border: OutlineInputBorder()),
          items: const [
            .new(value: .topLeft, child: Text('Top left')),
            .new(value: .topCenter, child: Text('Top center')),
            .new(value: .topRight, child: Text('Top right')),
            .new(value: .centerLeft, child: Text('Center left')),
            .new(value: .center, child: Text('Center')),
            .new(value: .centerRight, child: Text('Center right')),
            .new(value: .bottomLeft, child: Text('Bottom left')),
            .new(value: .bottomCenter, child: Text('Bottom center')),
            .new(value: .bottomRight, child: Text('Bottom right')),
          ],
          onChanged: (alignment) {
            if (alignment != null) {
              environment.updateAlignment(alignment);
            }
          },
        ),
        const SizedBox(height: 18),
        DropdownButtonFormField<HippoUiPreviewViewport>(
          initialValue: viewportState.viewport,
          decoration: const InputDecoration(labelText: 'Viewport', border: OutlineInputBorder()),
          items: const [
            .new(value: .responsive, child: Text('Responsive')),
            .new(value: .phoneCompact, child: Text('Phone compact')),
            .new(value: .phoneRegular, child: Text('Phone regular')),
            .new(value: .tabletPortrait, child: Text('Tablet portrait')),
            .new(value: .tabletLandscape, child: Text('Tablet landscape')),
            .new(value: .desktop, child: Text('Desktop')),
          ],
          onChanged: (viewport) {
            if (viewport != null) {
              environment.updateViewport(viewport);
            }
          },
        ),
        const SizedBox(height: 18),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: const Text('Grid'),
          value: gridState.enabled,
          onChanged: environment.updateGridEnabled,
        ),
        Text('Grid size: ${gridState.size.toStringAsFixed(0)}px'),
        Slider(
          value: gridState.size,
          min: 2,
          max: 64,
          divisions: 62,
          onChanged: environment.updateGridSize,
        ),
        const SizedBox(height: 18),
        Text('Zoom: ${zoomState.scale.toStringAsFixed(2)}x'),
        Slider(
          value: zoomState.scale,
          min: 0.25,
          max: 4,
          divisions: 75,
          onChanged: environment.updateZoomScale,
        ),
      ],
    );
  }
}

final class _OptionControl extends StatelessWidget {
  const _OptionControl({required this.option, required this.value, required this.onChanged});

  final HippoUiGeneratedOption option;

  final Object? value;

  final ValueChanged<Object?> onChanged;

  @override
  Widget build(BuildContext context) {
    final label = option.label ?? option.key;

    return switch (option) {
      HippoUiGeneratedBooleanOption booleanOption => SwitchListTile(
        contentPadding: EdgeInsets.zero,
        title: Text(label),
        value: value as bool? ?? booleanOption.defaultValue,
        onChanged: onChanged,
      ),
      HippoUiGeneratedIntegerOption integerOption
          when integerOption.min != null && integerOption.max != null =>
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text('$label: ${value as int? ?? integerOption.defaultValue}'),
            Slider(
              value: (value as int? ?? integerOption.defaultValue).toDouble(),
              min: integerOption.min!.toDouble(),
              max: integerOption.max!.toDouble(),
              divisions: integerOption.max! - integerOption.min!,
              onChanged: (value) => onChanged(value.round()),
            ),
          ],
        ),
      HippoUiGeneratedTextOption textOption => TextFormField(
        key: ValueKey(option.key),
        initialValue: value as String? ?? textOption.defaultValue,
        decoration: InputDecoration(labelText: label, border: const OutlineInputBorder()),
        onChanged: onChanged,
      ),
      HippoUiGeneratedEnumOption enumOption => DropdownButtonFormField<String>(
        initialValue: value as String? ?? enumOption.defaultValue,
        decoration: InputDecoration(labelText: label, border: const OutlineInputBorder()),
        items: [
          for (final optionValue in enumOption.values)
            .new(value: optionValue.value, child: Text(optionValue.label ?? optionValue.value)),
        ],
        onChanged: (value) {
          if (value != null) {
            onChanged(value);
          }
        },
      ),
      _ => Text('$label: unsupported option'),
    };
  }
}
