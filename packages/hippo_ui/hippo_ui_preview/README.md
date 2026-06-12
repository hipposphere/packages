# hippo_ui_preview

Framework-neutral preview runtime state for Hipposphere UI playgrounds.

This package owns preview environment state, playground configuration, mutable
playground control, and serializable addon models. It intentionally contains no
Flutter widgets.

## Runtime Types

- `HippoUiPlaygroundController`
- `HippoUiPlaygroundState`
- `HippoUiPlaygroundConfiguration`
- `HippoUiPreviewEnvironmentState`
- `HippoUiPreviewScenario`
- `HippoUiPreviewScenarioSet`
- `HippoUiPreviewSession`
- `HippoUiPreviewSessionUrlCodec`
- `HippoUiPreviewAddon<TState>`
- `HippoUiPreviewAddonState`

`HippoUiPreviewSession` stores a selected preview id, option values, and
environment addon state. `HippoUiPreviewSessionUrlCodec` encodes that session as
a URL-safe string for deep links and bug repro URLs.

`HippoUiPreviewScenario` adds a stable scenario id, display name, optional
description, and tags around a session. Use `HippoUiPreviewScenarioSet` to group
named states for docs, review apps, and visual regression jobs.

## Built-In Addons

- `ThemeTypeAddon`
- `GridAddon`
- `ZoomAddon`

Addon state is JSON-encodable and keyed by addon id in
`HippoUiPreviewEnvironmentState`.

## Validation

```sh
dart analyze packages/hippo_ui_preview
```
