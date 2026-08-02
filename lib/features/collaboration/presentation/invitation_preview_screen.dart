import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/errors/api_exception.dart';
import '../../../shared/widgets/hitched_illustration.dart';
import '../../auth/presentation/auth_controller.dart';
import '../../weddings/presentation/wedding_workspace_controller.dart';
import '../domain/collaboration_models.dart';
import 'collaboration_controller.dart';

class InvitationPreviewScreen extends ConsumerStatefulWidget {
  const InvitationPreviewScreen({required this.token, super.key});

  final String token;

  @override
  ConsumerState<InvitationPreviewScreen> createState() =>
      _InvitationPreviewScreenState();
}

class _InvitationPreviewScreenState
    extends ConsumerState<InvitationPreviewScreen> {
  bool _isAccepting = false;
  Object? _acceptError;

  Future<void> _accept(WeddingInvitationPreview preview) async {
    setState(() {
      _isAccepting = true;
      _acceptError = null;
    });
    try {
      await ref
          .read(collaborationRepositoryProvider)
          .acceptInvitation(widget.token);
      await ref.read(weddingWorkspaceProvider.notifier).refresh();
      final workspace = ref.read(weddingWorkspaceProvider).value;
      final wedding = workspace?.weddings
          .where((item) => item.id == preview.weddingId)
          .firstOrNull;
      if (wedding != null) {
        await ref
            .read(weddingWorkspaceProvider.notifier)
            .selectWedding(wedding);
      }
      if (mounted) context.go('/home');
    } catch (error) {
      if (mounted) {
        setState(() {
          _isAccepting = false;
          _acceptError = error;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final preview = ref.watch(invitationPreviewProvider(widget.token));
    final user = ref.watch(authControllerProvider).value;
    return Scaffold(
      appBar: AppBar(title: const Text('Wedding invitation')),
      body: preview.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => _PreviewError(
          error: error,
          onRetry: () =>
              ref.invalidate(invitationPreviewProvider(widget.token)),
        ),
        data: (data) => Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(28),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 460),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(28),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const HitchedIllustration.mark(width: 120, height: 80),
                      const SizedBox(height: 18),
                      Text(
                        'You are invited to plan',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        data.weddingName,
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                      if (data.weddingDate != null ||
                          data.location.isNotEmpty) ...[
                        const SizedBox(height: 14),
                        Text(
                          [
                            if (data.weddingDate != null)
                              _date(data.weddingDate!),
                            if (data.location.isNotEmpty) data.location,
                          ].join(' • '),
                          textAlign: TextAlign.center,
                        ),
                      ],
                      const SizedBox(height: 20),
                      Chip(label: Text(data.status.label)),
                      const SizedBox(height: 8),
                      Text(
                        'Invitation for ${data.email}',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      if (_acceptError != null) ...[
                        const SizedBox(height: 16),
                        Text(
                          _message(_acceptError!),
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.error,
                          ),
                        ),
                      ],
                      const SizedBox(height: 24),
                      if (!data.canAccept)
                        Text(
                          'This invitation is ${data.status.label.toLowerCase()}.',
                          textAlign: TextAlign.center,
                        )
                      else if (user == null) ...[
                        FilledButton(
                          onPressed: () => context.go(
                            '/login?invite=${Uri.encodeComponent(widget.token)}',
                          ),
                          child: const Text('Sign in to accept'),
                        ),
                        const SizedBox(height: 8),
                        TextButton(
                          onPressed: () => context.go(
                            '/register?invite=${Uri.encodeComponent(widget.token)}',
                          ),
                          child: const Text('Create an account'),
                        ),
                      ] else ...[
                        FilledButton.icon(
                          onPressed: _isAccepting ? null : () => _accept(data),
                          icon: _isAccepting
                              ? const SizedBox.square(
                                  dimension: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Icon(Icons.check_rounded),
                          label: const Text('Accept invitation'),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Signed in as ${user.email}',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _PreviewError extends StatelessWidget {
  const _PreviewError({required this.error, required this.onRetry});

  final Object error;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.link_off_rounded, size: 56),
            const SizedBox(height: 16),
            Text(_message(error), textAlign: TextAlign.center),
            const SizedBox(height: 16),
            OutlinedButton(onPressed: onRetry, child: const Text('Try again')),
          ],
        ),
      ),
    );
  }
}

String _message(Object error) {
  return error is ApiException ? error.displayMessage : error.toString();
}

String _date(DateTime date) {
  const months = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];
  return '${months[date.month - 1]} ${date.day}, ${date.year}';
}
