import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/errors/api_exception.dart';
import '../../../shared/widgets/submit_button.dart';
import '../domain/collaboration_models.dart';
import 'collaboration_controller.dart';

class CollaborationScreen extends ConsumerStatefulWidget {
  const CollaborationScreen({super.key});

  @override
  ConsumerState<CollaborationScreen> createState() =>
      _CollaborationScreenState();
}

class _CollaborationScreenState extends ConsumerState<CollaborationScreen> {
  final _emailController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _invite() async {
    if (!_formKey.currentState!.validate()) return;
    final succeeded = await ref
        .read(collaborationProvider.notifier)
        .invite(_emailController.text);
    if (succeeded && mounted) {
      _emailController.clear();
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Invitation created.')));
      return;
    }
    if (mounted) _showError();
  }

  void _showError() {
    final error = ref.read(collaborationProvider).value?.actionError;
    final message = error is ApiException
        ? error.displayMessage
        : error.toString();
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(collaborationProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('People and invitations')),
      body: state.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, _) => _CollaborationError(
          onRetry: () => ref.read(collaborationProvider.notifier).refresh(),
        ),
        data: (data) => RefreshIndicator(
          onRefresh: () => ref.read(collaborationProvider.notifier).refresh(),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 80),
            children: [
              Text(
                'Planning team',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 12),
              for (final member in data.members)
                Card(
                  child: ListTile(
                    leading: CircleAvatar(
                      child: Text(_initials(member.user.displayName)),
                    ),
                    title: Text(member.user.displayName),
                    subtitle: Text(member.user.email),
                    trailing: Chip(label: Text(_roleLabel(member.role))),
                  ),
                ),
              const SizedBox(height: 24),
              if (data.isOwner) ...[
                Text(
                  'Invite a partner',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 6),
                const Text(
                  'Invitations expire after seven days. Your partner must '
                  'accept using an account with this email address.',
                ),
                const SizedBox(height: 14),
                Form(
                  key: _formKey,
                  child: TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.done,
                    onFieldSubmitted: (_) => _invite(),
                    decoration: const InputDecoration(
                      labelText: 'Partner email',
                      prefixIcon: Icon(Icons.mail_outline_rounded),
                    ),
                    validator: (value) =>
                        value == null || !value.trim().contains('@')
                        ? 'Enter a valid email address.'
                        : null,
                  ),
                ),
                const SizedBox(height: 12),
                SubmitButton(
                  label: 'Create invitation',
                  isLoading: data.isMutating,
                  onPressed: _invite,
                ),
                const SizedBox(height: 28),
                Text(
                  'Invitations',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 10),
                if (data.invitations.isEmpty)
                  const Card(
                    child: Padding(
                      padding: EdgeInsets.all(20),
                      child: Text('No invitations yet.'),
                    ),
                  )
                else
                  for (final invitation in data.invitations)
                    _InvitationCard(invitation: invitation),
              ] else
                const Card(
                  child: Padding(
                    padding: EdgeInsets.all(18),
                    child: Text(
                      'Only the wedding owner can create or revoke invitations.',
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InvitationCard extends ConsumerWidget {
  const _InvitationCard({required this.invitation});

  final WeddingInvitation invitation;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 14, 8, 14),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    invitation.email,
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 5),
                  Row(
                    children: [
                      Icon(
                        Icons.circle,
                        size: 9,
                        color: _statusColor(invitation.status),
                      ),
                      const SizedBox(width: 5),
                      Text(
                        invitation.status.label,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Expires ${_shortDate(invitation.expiresAt)}',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            if (invitation.status == WeddingInvitationStatus.pending)
              PopupMenuButton<String>(
                onSelected: (action) async {
                  if (action == 'copy') {
                    await Clipboard.setData(
                      ClipboardData(text: invitation.token),
                    );
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Invite code copied.')),
                      );
                    }
                  } else {
                    await _revoke(context, ref);
                  }
                },
                itemBuilder: (_) => const [
                  PopupMenuItem(value: 'copy', child: Text('Copy invite code')),
                  PopupMenuItem(value: 'revoke', child: Text('Revoke')),
                ],
              )
            else if (invitation.status == WeddingInvitationStatus.revoked ||
                invitation.status == WeddingInvitationStatus.expired)
              TextButton(
                onPressed: () => _reissue(context, ref),
                child: const Text('Reissue'),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _revoke(BuildContext context, WidgetRef ref) async {
    final succeeded = await ref
        .read(collaborationProvider.notifier)
        .revoke(invitation.id);
    if (!succeeded && context.mounted) _showActionError(context, ref);
  }

  Future<void> _reissue(BuildContext context, WidgetRef ref) async {
    final succeeded = await ref
        .read(collaborationProvider.notifier)
        .invite(invitation.email);
    if (!succeeded && context.mounted) _showActionError(context, ref);
  }
}

class _CollaborationError extends StatelessWidget {
  const _CollaborationError({required this.onRetry});
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('People could not be loaded.'),
          const SizedBox(height: 12),
          OutlinedButton(onPressed: onRetry, child: const Text('Try again')),
        ],
      ),
    );
  }
}

void _showActionError(BuildContext context, WidgetRef ref) {
  final error = ref.read(collaborationProvider).value?.actionError;
  final message = error is ApiException
      ? error.displayMessage
      : error.toString();
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
}

String _initials(String name) {
  final words = name.trim().split(RegExp(r'\s+'));
  return words
      .where((word) => word.isNotEmpty)
      .take(2)
      .map((word) => word[0])
      .join()
      .toUpperCase();
}

String _roleLabel(String role) {
  return role == 'owner' ? 'Owner' : 'Partner';
}

String _shortDate(DateTime date) {
  const months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];
  return '${months[date.month - 1]} ${date.day}';
}

Color _statusColor(WeddingInvitationStatus status) {
  return switch (status) {
    WeddingInvitationStatus.pending => Colors.orange,
    WeddingInvitationStatus.accepted => Colors.green,
    WeddingInvitationStatus.revoked => Colors.red,
    WeddingInvitationStatus.expired => Colors.blueGrey,
  };
}
