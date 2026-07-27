# hippo_core_flutter

Flutter bindings and storage implementations for `hippo_core`.

This package contains:

- `DataSubjectBuilder`, combined subject builders, and text editing helpers.
- `BlocProvider`, `BlocDefiner`, and `MultiBlocProvider`.
- `ContentLane`, `ContentLayout`, `BoxAsSliver`, and `SliverSequence` for
  consistent box and sliver layouts without hiding their protocol boundary.
- `SharedPreferencesKeyValueStore`, `SecureKeyValueStore`, and `MockKeyValueStore`.
- `ApplicationSupportObjectStore` and `SecureKeyValueObjectStoreKeyring` for encrypted
  file-backed object caches.

## Content layouts

Apply one layout policy to either box or sliver content:

```dart
const layout = ContentLayout(maxWidth: 800);

ContentLane.box(
  layout: layout,
  child: Column(spacing: 16, children: const [Header(), Body()]),
);

ContentLane.sliver(
  layout: layout,
  sliver: SliverSequence(
    spacing: 16,
    slivers: const [
      BoxAsSliver(child: Header()),
      ItemsSliver(),
    ],
  ),
);
```

`BoxAsSliver` only bridges render protocols. Width and gutters belong to
`ContentLane`; spacing between box children belongs to their `Row` or `Column`.
