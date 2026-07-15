import 'package:flutter/widgets.dart';

import 'auth_controller.dart';
import 'state.dart';

/// Rebuilds whenever the current Hippobase authentication state changes.
final class HippobaseAuthBuilder extends StatelessWidget {
  const HippobaseAuthBuilder({super.key, this.controller, required this.builder});

  /// Uses the nearest [HippobaseAuthProvider] when omitted.
  final HippobaseAuthController? controller;
  final Widget Function(BuildContext context, HippobaseAuthState state) builder;

  @override
  Widget build(BuildContext context) {
    final auth = controller ?? HippobaseAuthController.of(context);
    return StreamBuilder<HippobaseAuthState>(
      stream: auth.state.stream,
      initialData: auth.state.value,
      builder: (context, snapshot) => builder(context, snapshot.requireData),
    );
  }
}
