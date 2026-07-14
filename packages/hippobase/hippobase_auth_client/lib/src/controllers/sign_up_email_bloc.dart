import 'package:flutter/widgets.dart';
import 'package:hippo_core/hippo_core.dart';

import '../models/login_error.dart';
import 'auth_controller.dart';

final class HippobaseSignUpEmailBloc extends BlocBase {
  HippobaseSignUpEmailBloc({required this.controller});

  final HippobaseAuthController controller;
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final DataSubject<bool> obscurePassword = DataSubject.seeded(true);
  final DataSubject<HippobaseLoginError?> error = DataSubject.seeded(null);
  final DataSubject<bool> isRunning = DataSubject.seeded(false);

  Future<void> signUp() async {
    if (isRunning.value) return;
    if (nameController.text.trim().isEmpty ||
        emailController.text.trim().isEmpty ||
        passwordController.text.isEmpty) {
      error.add(const HippobaseEmptyCredentials());
      return;
    }
    error.add(null);
    isRunning.add(true);
    try {
      await controller.signUpWithEmail(
        name: nameController.text,
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
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    obscurePassword.close();
    error.close();
    isRunning.close();
  }
}
