import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/entrance_animation.dart';
import '../../../shared/widgets/hitched_illustration.dart';
import '../../auth/presentation/auth_controller.dart';
import '../../dashboard/presentation/dashboard_overview.dart';
import '../domain/wedding.dart';
import 'wedding_workspace_controller.dart';
import 'wedding_onboarding_screen.dart';

class WeddingWorkspaceScreen extends ConsumerWidget {
  const WeddingWorkspaceScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final workspace = ref.watch(weddingWorkspaceProvider);
    return workspace.when(
      loading: () => const _LoadingWorkspace(),
      error: (error, _) => _WorkspaceError(
        onRetry: () => ref.read(weddingWorkspaceProvider.notifier).refresh(),
      ),
      data: (data) => data.selectedWedding == null
          ? const WeddingOnboardingScreen()
          : _PopulatedWorkspace(state: data),
    );
  }
}

class _PopulatedWorkspace extends ConsumerWidget {
  const _PopulatedWorkspace({required this.state});

  final WeddingWorkspaceState state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authControllerProvider).requireValue!;
    final wedding = state.selectedWedding!;

    return Scaffold(
      appBar: AppBar(
        title: DropdownButtonHideUnderline(
          child: DropdownButton<Wedding>(
            value: wedding,
            borderRadius: BorderRadius.circular(16),
            items: state.weddings
                .map(
                  (item) => DropdownMenuItem(
                    value: item,
                    child: Text(item.name, overflow: TextOverflow.ellipsis),
                  ),
                )
                .toList(),
            onChanged: (item) {
              if (item != null) {
                ref.read(weddingWorkspaceProvider.notifier).selectWedding(item);
              }
            },
          ),
        ),
        actions: [
          PopupMenuButton<String>(
            onSelected: (action) {
              if (action == 'logout') {
                ref.read(authControllerProvider.notifier).logout();
              } else if (action == 'collaboration') {
                context.push('/collaboration');
              } else if (action == 'accept_invitation') {
                context.push('/invite');
              } else if (action == 'settings') {
                context.push('/weddings/settings');
              }
            },
            itemBuilder: (_) => const [
              PopupMenuItem(value: 'settings', child: Text('Wedding settings')),
              PopupMenuItem(
                value: 'collaboration',
                child: Text('People and invitations'),
              ),
              PopupMenuItem(
                value: 'accept_invitation',
                child: Text('Accept invitation'),
              ),
              PopupMenuItem(value: 'logout', child: Text('Sign out')),
            ],
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/weddings/new'),
        icon: const Icon(Icons.add_rounded),
        label: const Text('Wedding'),
      ),
      body: RefreshIndicator(
        onRefresh: () => ref.read(weddingWorkspaceProvider.notifier).refresh(),
        child: ListView(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 100),
          children: [
            EntranceAnimation(
              child: Text(
                user.firstName.isEmpty
                    ? 'Welcome back'
                    : 'Hi, ${user.firstName}',
                style: Theme.of(context).textTheme.displaySmall,
              ),
            ),
            const SizedBox(height: 8),
            EntranceAnimation(
              delay: const Duration(milliseconds: 70),
              child: Text(
                'Here is the shape of your celebration today.',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ),
            const SizedBox(height: 24),
            EntranceAnimation(
              delay: const Duration(milliseconds: 130),
              child: _WeddingHero(wedding: wedding),
            ),
            const SizedBox(height: 28),
            const EntranceAnimation(
              delay: Duration(milliseconds: 210),
              child: DashboardOverview(),
            ),
          ],
        ),
      ),
    );
  }
}

class _WeddingHero extends StatelessWidget {
  const _WeddingHero({required this.wedding});

  final Wedding wedding;

  @override
  Widget build(BuildContext context) {
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.deepPlum, AppColors.plum, AppColors.rose],
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: const [
          BoxShadow(
            color: Color(0x3363364A),
            blurRadius: 24,
            offset: Offset(0, 12),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/images/wedding_table_hero.png',
              fit: BoxFit.cover,
            ),
          ),
          const Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xE663364A), Color(0x7063364A)],
                ),
              ),
            ),
          ),
          const Positioned(
            right: -22,
            top: -28,
            child: CircleAvatar(radius: 72, backgroundColor: Color(0x24EBCFA8)),
          ),
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  wedding.name,
                  style: Theme.of(
                    context,
                  ).textTheme.headlineSmall?.copyWith(color: Colors.white),
                ),
                if (wedding.location.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    wedding.location,
                    style: const TextStyle(color: Colors.white70, fontSize: 16),
                  ),
                ],
                const SizedBox(height: 24),
                Text(
                  _countdownLabel(wedding.weddingDate),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${wedding.memberCount} planner${wedding.memberCount == 1 ? '' : 's'} · ${wedding.currentUserRole}',
                  style: const TextStyle(color: Colors.white70),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _countdownLabel(DateTime? date) {
    if (date == null) return 'Date to be decided';
    final today = DateTime.now();
    final start = DateTime(today.year, today.month, today.day);
    final days = date.difference(start).inDays;
    if (days < 0) return 'Your wedding day has passed';
    if (days == 0) return 'Today is the day!';
    return '$days days to go';
  }
}

// Kept as the compact fallback layout for narrow embedded surfaces.
// ignore: unused_element
class _EmptyWorkspace extends StatelessWidget {
  const _EmptyWorkspace();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Hitched')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const HitchedIllustration(
                  asset: 'assets/illustrations/empty_wedding.svg',
                  width: 260,
                  height: 188,
                  semanticLabel: 'Wedding planning checklist',
                ),
                const SizedBox(height: 24),
                Text(
                  'Let’s create your wedding',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 10),
                const Text(
                  'Your tasks, guests, budget, vendors, and schedule will all live here.',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 28),
                FilledButton.icon(
                  onPressed: () => context.push('/weddings/new'),
                  icon: const Icon(Icons.add_rounded),
                  label: const Text('Create wedding'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _LoadingWorkspace extends StatelessWidget {
  const _LoadingWorkspace();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}

class _WorkspaceError extends StatelessWidget {
  const _WorkspaceError({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.cloud_off_outlined, size: 56),
              const SizedBox(height: 16),
              const Text('We could not load your weddings.'),
              const SizedBox(height: 16),
              OutlinedButton(
                onPressed: onRetry,
                child: const Text('Try again'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
