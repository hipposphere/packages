# hippo_ui_preview_flutter

Flutter builders and addons for Hipposphere UI preview playgrounds.

This package bridges `hippo_ui_preview` state into Flutter widgets. It does not
own the playground layout; callers provide the actual widgets through builder
callbacks.

## Builders

- `HippoUiPreviewFlutterBuilder` receives a `HippoUiPreviewEnvironmentState`.
- `HippoUiPlaygroundFlutterBuilder` listens to a `HippoUiPlaygroundController`
  with `DataSubjectBuilder` and exposes the active playground state and
  configuration.
- `HippoUiPreviewGridBuilder` applies `GridAddonState` to a Flutter subtree.
- `HippoUiPreviewHitboxBuilder` applies `HitboxAddonState` to a Flutter subtree.
- `HippoUiPreviewLocaleBuilder` applies `LocaleAddonState` to a Flutter subtree.
- `HippoUiPreviewSharedAddonsBuilder` applies common layout/debug addon states.
- `HippoUiPreviewThemeTypeBuilder` applies `ThemeTypeAddonState` to a Flutter subtree.
- `HippoUiPreviewWidgetOutlineBuilder` applies `WidgetOutlineAddon` state to a Flutter subtree.
- `HippoUiPreviewZoomBuilder` applies `ZoomAddonState` to a Flutter subtree.
- `HippoUiIconCatalogListBuilder` rebuilds with filtered icon catalog results.

## Controllers

- `HippoUiIconCatalogController` owns icon catalog state and search input.

## Flutter Addons

- `AlignmentAddon`
- `HitboxAddon`
- `LocaleAddon`
- `ViewportAddon`
- `WidgetOutlineAddon`

Framework-neutral addons such as theme type, grid, and zoom are exported from
`hippo_ui_preview`.

Use `HippoUiPreviewSession` from `hippo_ui_preview` to serialize the active
preview id, option values, and addon environment state for deep links or saved
playground sessions.
`HippoUiPreviewSessionUrlCodec` turns those sessions into compact URL-safe
strings that can be carried in query parameters.

## Example

The runnable example lives in:

```text
packages/hippo_ui_preview_flutter/example
```

Run it with:

```sh
cd packages/hippo_ui_preview_flutter/example
flutter run
```

## Validation

```sh
flutter analyze packages/hippo_ui_preview_flutter
flutter analyze packages/hippo_ui_preview_flutter/example
```
