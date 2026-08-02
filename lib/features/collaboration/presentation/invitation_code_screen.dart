import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class InvitationCodeScreen extends StatefulWidget {
  const InvitationCodeScreen({super.key});

  @override
  State<InvitationCodeScreen> createState() => _InvitationCodeScreenState();
}

class _InvitationCodeScreenState extends State<InvitationCodeScreen> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _continue() {
    final token = _controller.text.trim();
    if (token.isNotEmpty) context.push('/invite/$token');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Accept invitation')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Paste the invitation code shared by the wedding owner.',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _controller,
                autofocus: true,
                autocorrect: false,
                textInputAction: TextInputAction.done,
                onSubmitted: (_) => _continue(),
                decoration: const InputDecoration(
                  labelText: 'Invitation code',
                  prefixIcon: Icon(Icons.key_outlined),
                ),
              ),
              const SizedBox(height: 20),
              FilledButton(
                onPressed: _continue,
                child: const Text('Preview invitation'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
