import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../shared/widgets/hitched_illustration.dart';
import '../../auth/presentation/auth_controller.dart';
import '../../collaboration/domain/collaboration_models.dart';
import '../../collaboration/presentation/collaboration_controller.dart';

class WeddingOnboardingScreen extends ConsumerWidget {
  const WeddingOnboardingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final invitations = ref.watch(pendingInvitationsProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Welcome to Hitched'),
        actions: [
          IconButton(
            tooltip: 'Sign out',
            onPressed: () => ref.read(authControllerProvider.notifier).logout(),
            icon: const Icon(Icons.logout_rounded),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async => ref.invalidate(pendingInvitationsProvider),
        child: ListView(
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 40),
          children: [
            Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 520),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _PhotoHero(),
                    const SizedBox(height: 24),
                    Text(
                      'Create or join a wedding',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Start a shared planning space, or join one when someone has invited you.',
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    FilledButton.icon(
                      onPressed: () => context.push('/weddings/new'),
                      icon: const Icon(Icons.favorite_outline_rounded),
                      label: const Text('Create a wedding'),
                    ),
                    const SizedBox(height: 12),
                    OutlinedButton.icon(
                      onPressed: () => context.push('/invite'),
                      icon: const Icon(Icons.mail_outline_rounded),
                      label: const Text('Join with an invitation code'),
                    ),
                    const SizedBox(height: 30),
                    invitations.when(
                      loading: () =>
                          const Center(child: CircularProgressIndicator()),
                      error: (_, _) => Card(
                        child: ListTile(
                          leading: const Icon(Icons.cloud_off_outlined),
                          title: const Text('Could not check your invitations'),
                          trailing: TextButton(
                            onPressed: () =>
                                ref.invalidate(pendingInvitationsProvider),
                            child: const Text('Retry'),
                          ),
                        ),
                      ),
                      data: (items) => items.isEmpty
                          ? const SizedBox.shrink()
                          : _PendingInvitations(invitations: items),
                    ),
                    const SizedBox(height: 22),
                    const Center(
                      child: HitchedIllustration(
                        asset: 'assets/illustrations/empty_wedding.svg',
                        width: 180,
                        height: 130,
                        semanticLabel: 'Wedding planning checklist',
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PhotoHero extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(28),
      child: SizedBox(
        height: 210,
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.asset(
              'assets/images/wedding_table_hero.png',
              fit: BoxFit.cover,
            ),
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, Color(0xC963364A)],
                ),
              ),
            ),
            Align(
              alignment: Alignment.bottomLeft,
              child: Padding(
                padding: const EdgeInsets.all(22),
                child: Text(
                  'Your plans start here',
                  style: Theme.of(
                    context,
                  ).textTheme.headlineSmall?.copyWith(color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PendingInvitations extends StatelessWidget {
  const _PendingInvitations({required this.invitations});

  final List<WeddingInvitation> invitations;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Invitations waiting for you',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 10),
        ...invitations.map(
          (invitation) => Card(
            child: ListTile(
              contentPadding: const EdgeInsets.fromLTRB(18, 10, 10, 10),
              leading: const CircleAvatar(
                child: Icon(Icons.mark_email_unread_outlined),
              ),
              title: Text(
                invitation.weddingName.isEmpty
                    ? 'Wedding invitation'
                    : invitation.weddingName,
              ),
              subtitle: Text(
                [
                  if (invitation.location.isNotEmpty) invitation.location,
                  'Invited by ${invitation.invitedBy?.displayName ?? 'a wedding owner'}',
                ].join(' · '),
              ),
              trailing: const Icon(Icons.chevron_right_rounded),
              onTap: () => context.push('/invite/${invitation.token}'),
            ),
          ),
        ),
      ],
    );
  }
}
