import 'package:flutter/widgets.dart';
import 'package:hippo_core_flutter/hippo_core_flutter.dart';

import 'auth_controller.dart';

/// Makes a [HippobaseAuthController] available to descendant auth widgets.
///
/// The provider does not own the controller. The code that creates the
/// controller remains responsible for disposing it.
final class HippobaseAuthProvider extends StatelessWidget {
  const HippobaseAuthProvider({super.key, required this.controller, required this.child});

  final HippobaseAuthController controller;
  final Widget child;

  static HippobaseAuthController of(BuildContext context) {
    return HippobaseAuthController.of(context);
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<HippobaseAuthController>(bloc: controller, child: child);
  }
}
