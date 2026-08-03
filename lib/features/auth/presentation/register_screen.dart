import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/errors/api_exception.dart';
import '../../../shared/widgets/auth_scaffold.dart';
import '../../../shared/widgets/form_journey_image.dart';
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
  final _keys = List.generate(4, (_) => GlobalKey<FormState>());
  final _firstName = TextEditingController();
  final _lastName = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  var _step = 0;
  var _obscurePassword = true;

  @override
  void dispose() {
    _firstName.dispose();
    _lastName.dispose();
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  void _continue() {
    if (_step < 4 && _keys[_step].currentState!.validate()) {
      setState(() => _step++);
    }
  }

  Future<void> _submit() async {
    final succeeded = await ref
        .read(authControllerProvider.notifier)
        .register(
          firstName: _firstName.text,
          lastName: _lastName.text,
          email: _email.text,
          password: _password.text,
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
    final auth = ref.watch(authControllerProvider);
    const labels = ['First name', 'Last name', 'Email', 'Password', 'Review'];
    return AuthScaffold(
      children: [
        const FormJourneyImage(),
        const SizedBox(height: 22),
        Text(
          _step == 4 ? 'Everything looks lovely' : _headings[_step],
          style: Theme.of(context).textTheme.displaySmall,
        ),
        const SizedBox(height: 8),
        Text(_supportingText, style: Theme.of(context).textTheme.bodyLarge),
        const SizedBox(height: 24),
        ProgressStepper(currentStep: _step, labels: labels),
        const SizedBox(height: 24),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 260),
          child: _step == 4 ? _review(auth.isLoading) : _inputStep(),
        ),
        if (_step > 0 && !auth.isLoading) ...[
          const SizedBox(height: 8),
          TextButton.icon(
            onPressed: () => setState(() => _step--),
            icon: const Icon(Icons.arrow_back_rounded),
            label: const Text('Back'),
          ),
        ],
        const SizedBox(height: 4),
        TextButton(
          onPressed: auth.isLoading
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

  static const _headings = [
    'What should we call you?',
    'And your family name?',
    'Where can we reach you?',
    'Keep your plans safe',
  ];

  String get _supportingText => switch (_step) {
    0 => 'Let’s begin with your first name.',
    1 => 'This completes your profile.',
    2 =>
      widget.inviteToken == null
          ? 'Use the email you want linked to your plans.'
          : 'Use the email that received your invitation.',
    3 => 'Choose at least 8 characters.',
    _ => 'Review your details before we begin.',
  };

  Widget _inputStep() {
    final config = switch (_step) {
      0 => (
        controller: _firstName,
        label: 'First name',
        icon: Icons.person_outline_rounded,
        keyboard: TextInputType.name,
        obscure: false,
      ),
      1 => (
        controller: _lastName,
        label: 'Last name',
        icon: Icons.badge_outlined,
        keyboard: TextInputType.name,
        obscure: false,
      ),
      2 => (
        controller: _email,
        label: 'Email',
        icon: Icons.mail_outline_rounded,
        keyboard: TextInputType.emailAddress,
        obscure: false,
      ),
      _ => (
        controller: _password,
        label: 'Password',
        icon: Icons.lock_outline_rounded,
        keyboard: TextInputType.visiblePassword,
        obscure: _obscurePassword,
      ),
    };
    return Form(
      key: _keys[_step],
      child: Column(
        key: ValueKey('register-$_step'),
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextFormField(
            controller: config.controller,
            autofocus: true,
            keyboardType: config.keyboard,
            obscureText: config.obscure,
            textCapitalization: _step < 2
                ? TextCapitalization.words
                : TextCapitalization.none,
            textInputAction: TextInputAction.done,
            onFieldSubmitted: (_) => _continue(),
            decoration: InputDecoration(
              labelText: config.label,
              prefixIcon: Icon(config.icon),
              suffixIcon: _step == 3
                  ? IconButton(
                      onPressed: () =>
                          setState(() => _obscurePassword = !_obscurePassword),
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                      ),
                    )
                  : null,
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) return 'Required.';
              if (_step == 2 && !value.contains('@')) {
                return 'Enter a valid email address.';
              }
              if (_step == 3 && value.length < 8) {
                return 'Password must be at least 8 characters.';
              }
              return null;
            },
          ),
          const SizedBox(height: 22),
          FilledButton.icon(
            onPressed: _continue,
            icon: const Icon(Icons.arrow_forward_rounded),
            label: Text(_step == 3 ? 'Review account' : 'Continue'),
          ),
        ],
      ),
    );
  }

  Widget _review(bool loading) => Column(
    key: const ValueKey('register-review'),
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      Card(
        child: ListTile(
          contentPadding: const EdgeInsets.all(18),
          leading: const CircleAvatar(child: Icon(Icons.favorite_rounded)),
          title: Text('${_firstName.text.trim()} ${_lastName.text.trim()}'),
          subtitle: Text(_email.text.trim()),
        ),
      ),
      const SizedBox(height: 20),
      SubmitButton(
        label: widget.inviteToken == null
            ? 'Create my account'
            : 'Create account and view invitation',
        isLoading: loading,
        onPressed: _submit,
      ),
    ],
  );
}
