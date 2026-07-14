import 'package:flutter/material.dart';

import '../../controllers/auth_controller.dart';
import '../../controllers/sign_in_email_bloc.dart';
import '../../models/login_error.dart';

final class HippobaseAuthLoginForm extends StatefulWidget {
  const HippobaseAuthLoginForm({super.key, required this.controller});

  final HippobaseAuthController controller;

  @override
  State<HippobaseAuthLoginForm> createState() => _HippobaseAuthLoginFormState();
}

final class _HippobaseAuthLoginFormState extends State<HippobaseAuthLoginForm> {
  late HippobaseSignInEmailBloc bloc;

  @override
  void initState() {
    super.initState();
    bloc = HippobaseSignInEmailBloc(controller: widget.controller);
  }

  @override
  void didUpdateWidget(covariant HippobaseAuthLoginForm oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      bloc.dispose();
      bloc = HippobaseSignInEmailBloc(controller: widget.controller);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AutofillGroup(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          TextField(
            controller: bloc.emailController,
            autofillHints: const <String>[AutofillHints.email],
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(labelText: 'Email'),
          ),
          TextField(
            controller: bloc.passwordController,
            autofillHints: const <String>[AutofillHints.password],
            obscureText: true,
            onSubmitted: (_) => bloc.signIn(),
            decoration: const InputDecoration(labelText: 'Password'),
          ),
          StreamBuilder<HippobaseLoginError?>(
            stream: bloc.error.stream,
            initialData: bloc.error.value,
            builder: (context, snapshot) {
              final error = snapshot.data;
              return error == null
                  ? const SizedBox.shrink()
                  : Text(
                      hippobaseLoginErrorMessage(error),
                      style: TextStyle(color: Theme.of(context).colorScheme.error),
                    );
            },
          ),
          StreamBuilder<bool>(
            stream: bloc.isRunning.stream,
            initialData: bloc.isRunning.value,
            builder: (context, snapshot) {
              final running = snapshot.data ?? false;
              return FilledButton(
                onPressed: running ? null : bloc.signIn,
                child: running
                    ? const SizedBox.square(
                        dimension: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Sign in'),
              );
            },
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    bloc.dispose();
    super.dispose();
  }
}
