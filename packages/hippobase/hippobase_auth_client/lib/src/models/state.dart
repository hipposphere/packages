import 'session.dart';

sealed class HippobaseAuthState {
  const HippobaseAuthState();

  HippobaseAuthSession? get session;
}

final class HippobaseAuthLoading extends HippobaseAuthState {
  const HippobaseAuthLoading();

  @override
  HippobaseAuthSession? get session => null;
}

final class HippobaseAuthenticated extends HippobaseAuthState {
  const HippobaseAuthenticated(this.session);

  @override
  final HippobaseAuthSession session;
}

final class HippobaseUnauthenticated extends HippobaseAuthState {
  const HippobaseUnauthenticated();

  @override
  HippobaseAuthSession? get session => null;
}

final class HippobaseAuthFailure extends HippobaseAuthState {
  const HippobaseAuthFailure(this.error);

  final Object error;

  @override
  HippobaseAuthSession? get session => null;
}
