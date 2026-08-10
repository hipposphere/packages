## 0.1.13

- Fix frame-rate ticker interval calculation on Flutter web.

## 0.1.12

- Move `SharedPreferencesKeyValueStore` to `hippo_core_flutter_shared_preferences`.
- Move `SecureKeyValueStore` to `hippo_core_flutter_secure_storage`.
- Remove the `shared_preferences` and `flutter_secure_storage` dependencies.
- Add `DataValueBuilder` and cached two-, three-, and four-value builders.
- Keep existing subject builders as deprecated compatibility wrappers.
- Add `FrameRateTickerProviderStateMixin` for reusable throttled animations.
- Correct builder source replacement, nullable-value, error, and lifecycle
  behavior.

## 0.1.11

- Add `FrameRateTickerProvider` for driving standard Flutter animation
  controllers at a deliberate maximum engine frame rate.

## 0.1.10

- Add `ResourceLeaseBuilder` for identity-scoped resource acquisition and release.

## 0.1.9

- Add `OwnedBlocProvider` for route- and feature-scoped bloc creation and
  automatic disposal.

## 0.1.5

- Add `ApplicationSupportObjectStore` and secure key-value object-store keyring implementations.

## 0.1.0

- Add Flutter builders and provider widgets for `hippo_core`.
- Add shared preferences, secure storage, and mock `KeyValueStore` implementations.
