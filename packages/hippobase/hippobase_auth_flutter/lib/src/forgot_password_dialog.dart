import 'package:flutter/material.dart';

import 'auth_controller.dart';

final class HippobaseForgotPasswordDialog {
  const HippobaseForgotPasswordDialog({required this.controller, this.initialEmail = ''});

  final HippobaseAuthController controller;
  final String initialEmail;

  Future<void> open(BuildContext context) async {
    final email = TextEditingController(text: initialEmail);
    try {
      await showDialog<void>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Reset password'),
          content: TextField(
            controller: email,
            keyboardType: TextInputType.emailAddress,
            autofillHints: const <String>[AutofillHints.email],
            decoration: const InputDecoration(labelText: 'Email'),
          ),
          actions: <Widget>[
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
            FilledButton(
              onPressed: () async {
                await controller.client.requestPasswordReset(email.text.trim());
                if (context.mounted) Navigator.pop(context);
              },
              child: const Text('Send reset link'),
            ),
          ],
        ),
      );
    } finally {
      email.dispose();
    }
  }
}
