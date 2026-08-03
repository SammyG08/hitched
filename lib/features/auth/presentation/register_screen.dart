import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/errors/api_exception.dart';
import '../../../shared/widgets/auth_scaffold.dart';
import '../../../shared/widgets/progress_stepper.dart';
import '../../../shared/widgets/submit_button.dart';
import 'auth_controller.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({this.inviteToken, super.key});

  final String? inviteToken;

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _identityKey = GlobalKey<FormState>();
  final _accountKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  var _step = 0;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _continue() {
    final valid = _step == 0
        ? _identityKey.currentState!.validate()
        : _accountKey.currentState!.validate();
    if (valid) setState(() => _step++);
  }

  Future<void> _submit() async {
    final succeeded = await ref
        .read(authControllerProvider.notifier)
        .register(
          firstName: _firstNameController.text,
          lastName: _lastNameController.text,
          email: _emailController.text,
          password: _passwordController.text,
        );
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
    final authState = ref.watch(authControllerProvider);
    return AuthScaffold(
      children: [
        Text(
          _step == 2 ? 'Everything looks lovely' : 'Create your account',
          style: Theme.of(context).textTheme.displaySmall,
        ),
        const SizedBox(height: 8),
        Text(_subtitle, style: Theme.of(context).textTheme.bodyLarge),
        const SizedBox(height: 24),
        ProgressStepper(
          currentStep: _step,
          labels: const ['About you', 'Secure it', 'Review'],
        ),
        const SizedBox(height: 24),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 280),
          child: switch (_step) {
            0 => _identityStep(),
            1 => _accountStep(),
            _ => _reviewStep(authState.isLoading),
          },
        ),
        if (_step > 0 && !authState.isLoading) ...[
          const SizedBox(height: 10),
          TextButton.icon(
            onPressed: () => setState(() => _step--),
            icon: const Icon(Icons.arrow_back_rounded),
            label: const Text('Back'),
          ),
        ],
        const SizedBox(height: 8),
        TextButton(
          onPressed: authState.isLoading
              ? null
              : () => context.go(
                  widget.inviteToken == null
                      ? '/login'
                      : '/login?invite=${Uri.encodeComponent(widget.inviteToken!)}',
                ),
          child: const Text('Already have an account? Sign in'),
        ),
      ],
    );
  }

  String get _subtitle => switch (_step) {
    0 => 'Tell us who is beginning this planning journey.',
    1 => 'Choose the details you will use to return.',
    _ =>
      widget.inviteToken == null
          ? 'Your wedding workspace is one tap away.'
          : 'Create your account, then open your invitation.',
  };

  Widget _identityStep() => Form(
    key: _identityKey,
    child: Column(
      key: const ValueKey('identity'),
      children: [
        TextFormField(
          controller: _firstNameController,
          autofocus: true,
          textCapitalization: TextCapitalization.words,
          textInputAction: TextInputAction.next,
          decoration: const InputDecoration(
            labelText: 'First name',
            prefixIcon: Icon(Icons.person_outline_rounded),
          ),
          validator: _requiredName,
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _lastNameController,
          textCapitalization: TextCapitalization.words,
          textInputAction: TextInputAction.done,
          onFieldSubmitted: (_) => _continue(),
          decoration: const InputDecoration(
            labelText: 'Last name',
            prefixIcon: Icon(Icons.badge_outlined),
          ),
          validator: _requiredName,
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

  Widget _accountStep() => Form(
    key: _accountKey,
    child: Column(
      key: const ValueKey('account'),
      children: [
        TextFormField(
          controller: _emailController,
          autofocus: true,
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.next,
          decoration: const InputDecoration(
            labelText: 'Email',
            hintText: 'you@example.com',
            prefixIcon: Icon(Icons.mail_outline_rounded),
          ),
          validator: (value) => value == null || !value.contains('@')
              ? 'Enter a valid email address.'
              : null,
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _passwordController,
          obscureText: _obscurePassword,
          textInputAction: TextInputAction.done,
          onFieldSubmitted: (_) => _continue(),
          decoration: InputDecoration(
            labelText: 'Password',
            helperText: 'Use at least 8 characters.',
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
          validator: (value) => value == null || value.length < 8
              ? 'Password must be at least 8 characters.'
              : null,
        ),
        const SizedBox(height: 22),
        FilledButton.icon(
          onPressed: _continue,
          icon: const Icon(Icons.arrow_forward_rounded),
          label: const Text('Review account'),
        ),
      ],
    ),
  );

  Widget _reviewStep(bool isLoading) => Column(
    key: const ValueKey('review'),
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      Card(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              const CircleAvatar(
                radius: 28,
                child: Icon(Icons.favorite_rounded),
              ),
              const SizedBox(height: 12),
              Text(
                '${_firstNameController.text.trim()} ${_lastNameController.text.trim()}',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 4),
              Text(_emailController.text.trim()),
            ],
          ),
        ),
      ),
      const SizedBox(height: 20),
      SubmitButton(
        label: widget.inviteToken == null
            ? 'Create my account'
            : 'Create account and view invitation',
        isLoading: isLoading,
        onPressed: _submit,
      ),
    ],
  );

  String? _requiredName(String? value) =>
      value == null || value.trim().isEmpty ? 'Required.' : null;
}
