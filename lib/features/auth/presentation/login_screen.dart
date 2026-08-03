import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/errors/api_exception.dart';
import '../../../shared/widgets/auth_scaffold.dart';
import '../../../shared/widgets/form_journey_image.dart';
import '../../../shared/widgets/progress_stepper.dart';
import '../../../shared/widgets/submit_button.dart';
import 'auth_controller.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({this.inviteToken, super.key});
  final String? inviteToken;

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _emailKey = GlobalKey<FormState>();
  final _passwordKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();
  var _step = 0;
  var _obscurePassword = true;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  void _continue() {
    if (_emailKey.currentState!.validate()) setState(() => _step = 1);
  }

  Future<void> _submit() async {
    if (!_passwordKey.currentState!.validate()) return;
    final succeeded = await ref
        .read(authControllerProvider.notifier)
        .login(email: _email.text, password: _password.text);
    if (!succeeded && mounted) {
      final error = ref.read(authControllerProvider).error;
      final message = error is ApiException
          ? error.displayMessage
          : error.toString();
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authControllerProvider);
    return AuthScaffold(
      children: [
        const FormJourneyImage(),
        const SizedBox(height: 22),
        Text('Welcome back', style: Theme.of(context).textTheme.displaySmall),
        const SizedBox(height: 8),
        Text(
          _step == 0
              ? 'Let’s find your planning space.'
              : 'One final step, then you’re in.',
          style: Theme.of(context).textTheme.bodyLarge,
        ),
        const SizedBox(height: 24),
        ProgressStepper(
          currentStep: _step,
          labels: const ['Email', 'Password'],
        ),
        const SizedBox(height: 24),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 260),
          child: _step == 0 ? _emailStep() : _passwordStep(auth.isLoading),
        ),
        const SizedBox(height: 14),
        TextButton(
          onPressed: auth.isLoading
              ? null
              : () => context.go(
                  widget.inviteToken == null
                      ? '/register'
                      : '/register?invite=${Uri.encodeComponent(widget.inviteToken!)}',
                ),
          child: const Text('New to Hitched? Create an account'),
        ),
      ],
    );
  }

  Widget _emailStep() => Form(
    key: _emailKey,
    child: Column(
      key: const ValueKey('login-email'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextFormField(
          controller: _email,
          autofocus: true,
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.done,
          onFieldSubmitted: (_) => _continue(),
          decoration: const InputDecoration(
            labelText: 'Email',
            prefixIcon: Icon(Icons.mail_outline_rounded),
          ),
          validator: (value) => value == null || !value.contains('@')
              ? 'Enter a valid email address.'
              : null,
        ),
        const SizedBox(height: 22),
        FilledButton.icon(
          onPressed: _continue,
          icon: const Icon(Icons.arrow_forward_rounded),
          label: const Text('Continue'),
        ),
      ],
    ),
  );

  Widget _passwordStep(bool loading) => Form(
    key: _passwordKey,
    child: Column(
      key: const ValueKey('login-password'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextFormField(
          controller: _password,
          autofocus: true,
          obscureText: _obscurePassword,
          textInputAction: TextInputAction.done,
          onFieldSubmitted: (_) => _submit(),
          decoration: InputDecoration(
            labelText: 'Password',
            prefixIcon: const Icon(Icons.lock_outline_rounded),
            suffixIcon: IconButton(
              onPressed: () =>
                  setState(() => _obscurePassword = !_obscurePassword),
              icon: Icon(
                _obscurePassword
                    ? Icons.visibility_outlined
                    : Icons.visibility_off_outlined,
              ),
            ),
          ),
          validator: (value) =>
              value == null || value.isEmpty ? 'Enter your password.' : null,
        ),
        const SizedBox(height: 22),
        SubmitButton(label: 'Sign in', isLoading: loading, onPressed: _submit),
        TextButton.icon(
          onPressed: loading ? null : () => setState(() => _step = 0),
          icon: const Icon(Icons.arrow_back_rounded),
          label: Text('Change ${_email.text.trim()}'),
        ),
      ],
    ),
  );
}
