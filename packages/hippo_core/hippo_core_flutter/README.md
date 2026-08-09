# hippo_core_flutter

Flutter bindings and storage implementations for `hippo_core`.

This package contains:

- `DataSubjectBuilder`, combined subject builders, and text editing helpers.
- `BlocProvider`, `OwnedBlocProvider`, `BlocDefiner`, and `MultiBlocProvider`.
- `ResourceLeaseBuilder` for mounted, identity-scoped access to leased resources.
- `ContentLane`, `ContentLayout`, `BoxAsSliver`, and `SliverSequence` for
  consistent box and sliver layouts without hiding their protocol boundary.
- `MockKeyValueStore` for tests and in-memory app state.
- `ApplicationSupportObjectStore` and `SecureKeyValueObjectStoreKeyring` for encrypted
  file-backed object caches.
- `FrameRateTickerProvider` for ambient animations whose content frame rate is
  lower than the display refresh rate.

Persistent `KeyValueStore` adapters are opt-in packages so applications only
include the plugins they use:

- `hippo_core_flutter_shared_preferences` provides `SharedPreferencesKeyValueStore`.
- `hippo_core_flutter_secure_storage` provides `SecureKeyValueStore`.

## Frame-rate-limited animations

Use `FrameRateTickerProvider` with Flutter's regular `AnimationController` to
avoid scheduling the complete Flutter frame pipeline at the display refresh
rate when an animation only needs a lower content rate:

```dart
class _AmbientVisualState extends State<AmbientVisual> {
  final _tickerProvider = FrameRateTickerProvider(framesPerSecond: 30);
  AnimationController? _controller;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _tickerProvider.bind(context);
    _controller ??= AnimationController(
      vsync: _tickerProvider,
      duration: const Duration(seconds: 4),
    )..repeat();
  }

  @override
  void dispose() {
    _controller?.dispose();
    _tickerProvider.dispose();
    super.dispose();
  }
}
```

The provider follows `TickerMode` and the current Flutter view's display refresh
rate. It preserves `AnimationController` timing semantics by delivering ticks
on Flutter frames; delayed work drops intermediate visual frames instead of
slowing the animation.

This optimization only helps when `framesPerSecond` is below the display refresh
rate. It does not provide an independently composited widget subtree. Timer-
parked tickers are also invisible to `WidgetTester.pumpAndSettle`, so animation
tests should advance time explicitly with `pump`.

## Bloc ownership

Use `BlocProvider` to expose a bloc whose lifecycle is owned by a caller. Use
`OwnedBlocProvider` for a route or feature subtree that should create the bloc
once and dispose it automatically when that subtree unmounts:

```dart
OwnedBlocProvider<EditorBloc>.builder(
  create: () => EditorBloc(repository: repository),
  builder: (context, bloc) => EditorPage(bloc: bloc),
);
```

Ordinary rebuilds preserve the owned bloc. Give the provider a new key when an
intentional identity change should recreate it.

## Resource leases

Use `ResourceLeaseBuilder` when a mounted subtree should temporarily retain a cached resource:

```dart
ResourceLeaseBuilder<EditorBloc>(
  identity: documentId,
  acquire: () => editorCache.getOrCreateLease(documentId, () => EditorBloc(documentId)),
  builder: (context, bloc) => EditorPage(bloc: bloc),
);
```

Ordinary rebuilds preserve the lease. Changing `identity` acquires the replacement before
releasing the previous lease, and unmounting releases the active lease.

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
