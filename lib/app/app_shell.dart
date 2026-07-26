import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hitched/core/models/wedding_models.dart';
import 'package:hitched/core/state/app_controller.dart';
import 'package:hitched/features/bookings/presentation/bookings_screen.dart';
import 'package:hitched/features/budget/presentation/budget_screen.dart';
import 'package:hitched/features/dashboard/presentation/dashboard_home_screen.dart';
import 'package:hitched/features/guests/presentation/guests_screen.dart';
import 'package:hitched/features/marketplace/presentation/marketplace_screen.dart';
import 'package:hitched/features/todos/presentation/todos_screen.dart';
import 'package:hitched/features/vendor_studio/presentation/vendor_studio_screen.dart';

class AppShell extends ConsumerStatefulWidget {
  const AppShell({super.key});

  @override
  ConsumerState<AppShell> createState() => _AppShellState();
}

class _AppShellState extends ConsumerState<AppShell> {
  int selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(appControllerProvider).currentUser!;
    final destinations = user.role == UserRole.vendor
        ? _vendorDestinations
        : _coupleDestinations(user.role);
    final pages = user.role == UserRole.vendor
        ? _vendorPages
        : _couplePages(user.role);
    selectedIndex = selectedIndex.clamp(0, pages.length - 1);

    return LayoutBuilder(
      builder: (context, constraints) {
        final useRail = constraints.maxWidth >= 900;
        if (!useRail) {
          return Scaffold(
            body: pages[selectedIndex],
            bottomNavigationBar: NavigationBar(
              selectedIndex: selectedIndex,
              onDestinationSelected: (index) =>
                  setState(() => selectedIndex = index),
              destinations: destinations,
            ),
          );
        }
        return Scaffold(
          body: Row(
            children: [
              NavigationRail(
                selectedIndex: selectedIndex,
                onDestinationSelected: (index) =>
                    setState(() => selectedIndex = index),
                labelType: NavigationRailLabelType.all,
                destinations: destinations
                    .map(
                      (item) => NavigationRailDestination(
                        icon: item.icon,
                        selectedIcon: item.selectedIcon,
                        label: Text(item.label),
                      ),
                    )
                    .toList(),
              ),
              const VerticalDivider(width: 1),
              Expanded(child: pages[selectedIndex]),
            ],
          ),
        );
      },
    );
  }
}

const _vendorDestinations = [
  NavigationDestination(
    icon: Icon(Icons.dashboard_outlined),
    selectedIcon: Icon(Icons.dashboard),
    label: 'Studio',
  ),
  NavigationDestination(
    icon: Icon(Icons.event_available_outlined),
    selectedIcon: Icon(Icons.event_available),
    label: 'Inquiries',
  ),
];

const _vendorPages = [VendorStudioScreen(), BookingsScreen()];

List<NavigationDestination> _coupleDestinations(UserRole role) => [
  const NavigationDestination(
    icon: Icon(Icons.dashboard_outlined),
    selectedIcon: Icon(Icons.dashboard),
    label: 'Home',
  ),
  const NavigationDestination(
    icon: Icon(Icons.storefront_outlined),
    selectedIcon: Icon(Icons.storefront),
    label: 'Vendors',
  ),
  const NavigationDestination(
    icon: Icon(Icons.event_note_outlined),
    selectedIcon: Icon(Icons.event_note),
    label: 'Bookings',
  ),
  const NavigationDestination(
    icon: Icon(Icons.group_outlined),
    selectedIcon: Icon(Icons.group),
    label: 'Guests',
  ),
  const NavigationDestination(
    icon: Icon(Icons.checklist_outlined),
    selectedIcon: Icon(Icons.checklist),
    label: 'Todos',
  ),
  if (role == UserRole.groom)
    const NavigationDestination(
      icon: Icon(Icons.lock_outline),
      selectedIcon: Icon(Icons.lock),
      label: 'Budget',
    ),
];

List<Widget> _couplePages(UserRole role) => [
  const DashboardHomeScreen(),
  const MarketplaceScreen(),
  const BookingsScreen(),
  const GuestsScreen(),
  const TodosScreen(),
  if (role == UserRole.groom) const BudgetScreen(),
];
