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
          padding: const EdgeInsets.only(bottom: 100),
          children: [
            EntranceAnimation(child: _WeddingHero(wedding: wedding)),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 26, 24, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  EntranceAnimation(
                    delay: const Duration(milliseconds: 80),
                    child: Text(
                      user.firstName.isEmpty
                          ? 'Welcome back'
                          : 'Hi, ${user.firstName}',
                      style: Theme.of(context).textTheme.displaySmall,
                    ),
                  ),
                  const SizedBox(height: 8),
                  EntranceAnimation(
                    delay: const Duration(milliseconds: 140),
                    child: Text(
                      'Here is the shape of your celebration today.',
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  ),
                  const SizedBox(height: 28),
                  const EntranceAnimation(
                    delay: Duration(milliseconds: 210),
                    child: DashboardOverview(),
                  ),
                ],
              ),
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
    return ClipPath(
      clipper: const _MastheadCurveClipper(),
      child: SizedBox(
        height: 310,
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
                  stops: [0, 0.42, 1],
                  colors: [
                    Color(0x183E1F30),
                    Color(0x743E1F30),
                    Color(0xF43E1F30),
                  ],
                ),
              ),
            ),
            Positioned(
              left: 24,
              right: 24,
              top: 20,
              child: Row(
                children: [
                  _HeroBadge(
                    icon: wedding.isOwner
                        ? Icons.workspace_premium_outlined
                        : Icons.favorite_outline_rounded,
                    label: wedding.currentUserRole,
                  ),
                  const Spacer(),
                  _HeroBadge(
                    icon: Icons.people_outline_rounded,
                    label:
                        '${wedding.memberCount} planner${wedding.memberCount == 1 ? '' : 's'}',
                  ),
                ],
              ),
            ),
            Positioned(
              left: 24,
              right: 24,
              bottom: 42,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _countdownLabel(wedding.weddingDate).toUpperCase(),
                    style: const TextStyle(
                      color: AppColors.champagne,
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.4,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    wedding.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      height: 1.05,
                    ),
                  ),
                  if (wedding.location.isNotEmpty) ...[
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        const Icon(
                          Icons.location_on_outlined,
                          color: Colors.white70,
                          size: 18,
                        ),
                        const SizedBox(width: 5),
                        Expanded(
                          child: Text(
                            wedding.location,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 15,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
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

class _HeroBadge extends StatelessWidget {
  const _HeroBadge({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
      decoration: BoxDecoration(
        color: const Color(0xB33E1F30),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: const Color(0x55FFFFFF)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 15, color: AppColors.champagne),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _MastheadCurveClipper extends CustomClipper<Path> {
  const _MastheadCurveClipper();

  @override
  Path getClip(Size size) {
    const edgeLift = 26.0;
    return Path()
      ..lineTo(0, size.height - edgeLift)
      ..quadraticBezierTo(
        size.width / 2,
        size.height + 4,
        size.width,
        size.height - edgeLift,
      )
      ..lineTo(size.width, 0)
      ..close();
  }

  @override
  bool shouldReclip(covariant _MastheadCurveClipper oldClipper) => false;
}

// ignore: unused_element
class _WeddingHeroLegacy extends StatelessWidget {
  const _WeddingHeroLegacy({required this.wedding});

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
