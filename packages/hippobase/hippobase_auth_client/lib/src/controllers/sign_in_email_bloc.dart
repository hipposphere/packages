import 'package:flutter/widgets.dart';
import 'package:hippo_core/hippo_core.dart';
import 'package:hippo_core_flutter/hippo_core_flutter.dart';

import '../models/login_error.dart';
import 'auth_controller.dart';

final class HippobaseSignInEmailBloc extends BlocBase {
  HippobaseSignInEmailBloc({required this.controller});

  final HippobaseAuthController controller;
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final DataSubject<bool> obscurePassword = DataSubject.seeded(true);
  final DataSubject<HippobaseLoginError?> error = DataSubject.seeded(null);
  final DataSubject<bool> isRunning = DataSubject.seeded(false);

  Future<void> signIn() async {
    if (isRunning.value) return;
    if (emailController.text.trim().isEmpty || passwordController.text.isEmpty) {
      error.add(const HippobaseEmptyCredentials());
      return;
    }
    error.add(null);
    isRunning.add(true);
    try {
      await controller.signInWithEmail(
        email: emailController.text,
        password: passwordController.text,
      );
    } catch (failure) {
      error.add(hippobaseLoginError(failure));
    } finally {
      isRunning.add(false);
    }
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    obscurePassword.close();
    error.close();
    isRunning.close();
  }

  static HippobaseSignInEmailBloc of(BuildContext context) {
    return BlocProvider.of<HippobaseSignInEmailBloc>(context);
  }
}
