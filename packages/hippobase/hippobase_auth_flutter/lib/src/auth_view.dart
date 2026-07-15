import 'package:flutter/widgets.dart';

import 'auth_builder.dart';
import 'auth_controller.dart';
import 'session.dart';
import 'state.dart';

/// Routes the current auth state to an explicit loading, signed-out, signed-in,
/// or failure widget.
final class HippobaseAuthView extends StatelessWidget {
  const HippobaseAuthView({
    super.key,
    this.controller,
    required this.loadingBuilder,
    required this.unauthenticatedBuilder,
    required this.authenticatedBuilder,
    required this.failureBuilder,
  });

  /// Uses the nearest [HippobaseAuthProvider] when omitted.
  final HippobaseAuthController? controller;
  final WidgetBuilder loadingBuilder;
  final WidgetBuilder unauthenticatedBuilder;
  final Widget Function(BuildContext context, HippobaseAuthSession session) authenticatedBuilder;
  final Widget Function(BuildContext context, Object error) failureBuilder;

  @override
  Widget build(BuildContext context) {
    return HippobaseAuthBuilder(
      controller: controller,
      builder: (context, state) {
        return switch (state) {
          HippobaseAuthLoading() => loadingBuilder(context),
          HippobaseUnauthenticated() => unauthenticatedBuilder(context),
          HippobaseAuthenticated(:final session) => authenticatedBuilder(context, session),
          HippobaseAuthFailure(:final error) => failureBuilder(context, error),
        };
      },
    );
  }
}
