import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:hitched/core/models/wedding_models.dart';
import 'package:hitched/core/state/app_controller.dart';
import 'package:hitched/core/theme/theme.dart';
import 'package:hitched/core/widgets/hitched_widgets.dart';

class DashboardHomeScreen extends ConsumerWidget {
  const DashboardHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(appControllerProvider);
    final user = state.currentUser!;
    final days = state.couple.weddingDate.difference(DateTime.now()).inDays;
    return HitchedScaffold(
      title: user.role == UserRole.vendor
          ? 'Vendor dashboard'
          : '${state.couple.brideName} & ${state.couple.groomName}',
      subtitle: user.role == UserRole.vendor
          ? 'Manage your wedding business'
          : 'Wedding command room',
      actions: [
        IconButton(
          onPressed: () => ref.read(appControllerProvider.notifier).logout(),
          icon: const Icon(Icons.logout),
        ),
      ],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(34),
              gradient: const LinearGradient(
                colors: [AppColors.merlot, Color(0xFF9F4D55)],
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        DateFormat.yMMMMd().format(state.couple.weddingDate),
                        style: Theme.of(context).textTheme.displayMedium
                            ?.copyWith(color: Colors.white),
                      ),
                      Text(
                        state.couple.location,
                        style: const TextStyle(color: Colors.white70),
                      ),
                      const SizedBox(height: 14),
                      Text(
                        '$days days to go',
                        style: Theme.of(
                          context,
                        ).textTheme.titleMedium?.copyWith(color: Colors.white),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.favorite,
                  color: AppColors.champagne,
                  size: 64,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          LayoutBuilder(
            builder: (context, box) {
              final wide = box.maxWidth > 780;
              return GridView.count(
                crossAxisCount: wide ? 4 : 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: wide ? 1.25 : 1.08,
                children: [
                  StatCard(
                    label: 'Guest list',
                    value: '${state.guests.length}',
                    detail: 'people tracked',
                    icon: Icons.group_outlined,
                  ),
                  StatCard(
                    label: 'Todos',
                    value:
                        '${state.tasks.where((task) => !task.isDone).length}',
                    detail: 'open tasks',
                    icon: Icons.checklist_outlined,
                  ),
                  StatCard(
                    label: 'Bookings',
                    value: '${state.bookings.length}',
                    detail: 'vendor actions',
                    icon: Icons.event_available_outlined,
                  ),
                  StatCard(
                    label: 'Spent',
                    value: money(state.bookedSpendCents),
                    detail: user.role == UserRole.groom
                        ? 'visible to groom'
                        : 'booked vendors',
                    icon: Icons.payments_outlined,
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Planning pulse',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 12),
                  LinearProgressIndicator(
                    value:
                        state.tasks.where((task) => task.isDone).length /
                        state.tasks.length,
                    minHeight: 10,
                    borderRadius: BorderRadius.circular(99),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Complete shared tasks, shortlist vendors, and move booking requests through approval.',
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
