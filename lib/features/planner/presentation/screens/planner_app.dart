import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import 'package:hitched/core/theme/theme.dart';

final plannerProvider = StateNotifierProvider<PlannerController, PlannerState>(
  (ref) => PlannerController(),
);

enum UserRole { bride, groom, vendor }

class AppUser {
  const AppUser({required this.name, required this.email, required this.role});
  final String name;
  final String email;
  final UserRole role;
}

class VendorItem {
  const VendorItem({
    required this.name,
    required this.category,
    required this.description,
    required this.price,
    required this.imageUrl,
    required this.remarks,
  });
  final String name;
  final String category;
  final String description;
  final int price;
  final String imageUrl;
  final String remarks;
}

class PlannerState {
  const PlannerState({
    this.user,
    this.partnerName = 'Daniel Hart',
    this.weddingDate = '2027-04-18',
    this.location = 'The Glasshouse, Lagos',
    this.budget = 6500000,
    this.guests = const [
      'Maya Cole - attending',
      'Ade Martins - pending',
      'The Okafor family - attending',
    ],
    this.todos = const [
      'Confirm ceremony music',
      'Book makeup trial',
      'Review final guest seating',
    ],
    this.vendors = _seedVendors,
  });

  final AppUser? user;
  final String partnerName;
  final String weddingDate;
  final String location;
  final int budget;
  final List<String> guests;
  final List<String> todos;
  final List<VendorItem> vendors;

  PlannerState copyWith({
    AppUser? user,
    String? partnerName,
    String? weddingDate,
    String? location,
    int? budget,
    List<String>? guests,
    List<String>? todos,
    List<VendorItem>? vendors,
  }) {
    return PlannerState(
      user: user ?? this.user,
      partnerName: partnerName ?? this.partnerName,
      weddingDate: weddingDate ?? this.weddingDate,
      location: location ?? this.location,
      budget: budget ?? this.budget,
      guests: guests ?? this.guests,
      todos: todos ?? this.todos,
      vendors: vendors ?? this.vendors,
    );
  }
}

class PlannerController extends StateNotifier<PlannerState> {
  PlannerController() : super(const PlannerState());

  void registerCouple({
    required UserRole role,
    required String name,
    required String email,
    required String partnerName,
    required String weddingDate,
    required String location,
  }) {
    state = state.copyWith(
      user: AppUser(name: name, email: email, role: role),
      partnerName: partnerName,
      weddingDate: weddingDate,
      location: location,
    );
  }

  void registerVendor({
    required String ownerName,
    required String email,
    required VendorItem service,
  }) {
    state = state.copyWith(
      user: AppUser(name: ownerName, email: email, role: UserRole.vendor),
      vendors: [service, ...state.vendors],
    );
  }

  void loginAs(UserRole role) {
    final name = switch (role) {
      UserRole.bride => 'Amara Belle',
      UserRole.groom => 'Daniel Hart',
      UserRole.vendor => 'Opal Atelier',
    };
    state = state.copyWith(
      user: AppUser(
        name: name,
        email: '${name.toLowerCase().replaceAll(' ', '.')}@hitched.app',
        role: role,
      ),
    );
  }

  void logout() => state = const PlannerState();
  void setBudget(int value) => state = state.copyWith(budget: value);
  void addGuest(String guest) =>
      state = state.copyWith(guests: [guest, ...state.guests]);
  void addTodo(String todo) =>
      state = state.copyWith(todos: [todo, ...state.todos]);
}

const _seedVendors = [
  VendorItem(
    name: 'Opal Atelier',
    category: 'Bridal gowns',
    description: 'Hand-beaded gowns, veil styling, and private fittings.',
    price: 2400000,
    imageUrl:
        'https://images.unsplash.com/photo-1594552072238-b8a33785b261?q=80&w=1200&auto=format&fit=crop',
    remarks: 'Brides praise the fabric quality and calm fitting experience.',
  ),
  VendorItem(
    name: 'Maison Flora',
    category: 'Vendors',
    description:
        'Ceremony florals and reception installations with garden texture.',
    price: 3800000,
    imageUrl:
        'https://images.unsplash.com/photo-1464366400600-7168b8af9bc3?q=80&w=1200&auto=format&fit=crop',
    remarks: 'Known for lush spaces that still photograph cleanly.',
  ),
  VendorItem(
    name: 'Saffron Table',
    category: 'Catering',
    description: 'Modern plated dinners, cocktails, and dessert tables.',
    price: 5200000,
    imageUrl:
        'https://images.unsplash.com/photo-1555244162-803834f70033?q=80&w=1200&auto=format&fit=crop',
    remarks: 'Guests consistently mention the tasting menu and service.',
  ),
  VendorItem(
    name: 'Velvet Lens',
    category: 'Vendors',
    description:
        'Editorial photo and film direction for couples who dislike posing.',
    price: 4500000,
    imageUrl:
        'https://images.unsplash.com/photo-1519741497674-611481863552?q=80&w=1200&auto=format&fit=crop',
    remarks: 'Strong documentary eye and fast turnaround.',
  ),
  VendorItem(
    name: 'Pearl Room',
    category: 'Locations',
    description: 'Light-filled venue with a courtyard and 180 guest capacity.',
    price: 9000000,
    imageUrl:
        'https://images.unsplash.com/photo-1519225421980-715cb0215aed?q=80&w=1200&auto=format&fit=crop',
    remarks: 'Best for intimate ceremonies and clean modern receptions.',
  ),
];

class PlannerShell extends ConsumerWidget {
  const PlannerShell({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(plannerProvider);
    return state.user == null ? const AuthScreen() : const HomeScreen();
  }
}

class AuthScreen extends ConsumerStatefulWidget {
  const AuthScreen({super.key});
  @override
  ConsumerState<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends ConsumerState<AuthScreen> {
  UserRole role = UserRole.bride;
  final name = TextEditingController(text: 'Amara Belle');
  final email = TextEditingController(text: 'amara@hitched.app');
  final partner = TextEditingController(text: 'Daniel Hart');
  final date = TextEditingController(text: '2027-04-18');
  final location = TextEditingController(text: 'The Glasshouse, Lagos');
  final service = TextEditingController(text: 'Opal Atelier');

  @override
  Widget build(BuildContext context) {
    final isVendor = role == UserRole.vendor;
    return Scaffold(
      body: Stack(
        children: [
          const _Atmosphere(),
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 960),
                  child: Row(
                    children: [
                      Expanded(
                        child: _HeroCopy(
                          onDemo: (r) =>
                              ref.read(plannerProvider.notifier).loginAs(r),
                        ),
                      ),
                      const SizedBox(width: 28),
                      Expanded(
                        child: Card(
                          child: Padding(
                            padding: const EdgeInsets.all(24),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Create your wedding space',
                                  style: Theme.of(
                                    context,
                                  ).textTheme.displayMedium,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Choose bride, groom, or vendor. Couple registration creates and links both partner accounts.',
                                  style: Theme.of(context).textTheme.bodyMedium,
                                ),
                                const SizedBox(height: 18),
                                Wrap(
                                  spacing: 10,
                                  children: UserRole.values
                                      .map(
                                        (r) => ChoiceChip(
                                          label: Text(_roleLabel(r)),
                                          selected: role == r,
                                          onSelected: (_) =>
                                              setState(() => role = r),
                                        ),
                                      )
                                      .toList(),
                                ),
                                const SizedBox(height: 18),
                                _Field(
                                  controller: name,
                                  label: isVendor
                                      ? 'Owner name'
                                      : 'Your full name',
                                ),
                                _Field(controller: email, label: 'Email'),
                                if (!isVendor) ...[
                                  _Field(
                                    controller: partner,
                                    label: role == UserRole.bride
                                        ? 'Groom full name'
                                        : 'Bride full name',
                                  ),
                                  _Field(
                                    controller: date,
                                    label: 'Wedding date',
                                  ),
                                  _Field(
                                    controller: location,
                                    label: 'Wedding location',
                                  ),
                                ],
                                if (isVendor)
                                  _Field(
                                    controller: service,
                                    label: 'Service name',
                                  ),
                                const SizedBox(height: 12),
                                ElevatedButton(
                                  onPressed: _submit,
                                  child: Text(
                                    isVendor
                                        ? 'Open vendor studio'
                                        : 'Create linked couple account',
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ).animate().fadeIn(duration: 500.ms).slideX(begin: 0.08),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _submit() {
    final controller = ref.read(plannerProvider.notifier);
    if (role == UserRole.vendor) {
      controller.registerVendor(
        ownerName: name.text,
        email: email.text,
        service: VendorItem(
          name: service.text,
          category: 'Vendors',
          description:
              'Curated wedding service with images, remarks, and pricing.',
          price: 3200000,
          imageUrl:
              'https://images.unsplash.com/photo-1527529482837-4698179dc6ce?q=80&w=1200&auto=format&fit=crop',
          remarks: 'New listing ready for couples to review.',
        ),
      );
    } else {
      controller.registerCouple(
        role: role,
        name: name.text,
        email: email.text,
        partnerName: partner.text,
        weddingDate: date.text,
        location: location.text,
      );
    }
  }
}

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});
  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int index = 0;
  @override
  Widget build(BuildContext context) {
    final state = ref.watch(plannerProvider);
    final role = state.user!.role;
    final pages = role == UserRole.vendor
        ? const [_VendorStudio(), _Marketplace()]
        : const [_Dashboard(), _SharedPlanner(), _Marketplace(), _RoleRoom()];
    return Scaffold(
      body: Stack(
        children: [
          const _Atmosphere(),
          SafeArea(child: pages[index]),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: index,
        onDestinationSelected: (value) => setState(() => index = value),
        destinations: role == UserRole.vendor
            ? const [
                NavigationDestination(
                  icon: Icon(Icons.storefront_outlined),
                  label: 'Studio',
                ),
                NavigationDestination(
                  icon: Icon(Icons.auto_stories_outlined),
                  label: 'Listings',
                ),
              ]
            : const [
                NavigationDestination(
                  icon: Icon(Icons.dashboard_outlined),
                  label: 'Dashboard',
                ),
                NavigationDestination(
                  icon: Icon(Icons.favorite_border),
                  label: 'Shared',
                ),
                NavigationDestination(
                  icon: Icon(Icons.storefront_outlined),
                  label: 'Market',
                ),
                NavigationDestination(
                  icon: Icon(Icons.lock_person_outlined),
                  label: 'Role',
                ),
              ],
      ),
    );
  }
}

class _Dashboard extends ConsumerWidget {
  const _Dashboard();
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(plannerProvider);
    final spent = state.vendors
        .where((v) => v.price <= state.budget)
        .take(2)
        .fold<int>(0, (sum, v) => sum + v.price);
    return _Page(
      title:
          '${state.user!.name.split(' ').first} & ${state.partnerName.split(' ').first}',
      eyebrow: 'Wedding command room',
      actions: [
        IconButton(
          onPressed: () => ref.read(plannerProvider.notifier).logout(),
          icon: const Icon(Icons.logout),
        ),
      ],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _WideHero(state: state),
          const SizedBox(height: 18),
          LayoutBuilder(
            builder: (context, box) {
              final wide = box.maxWidth > 720;
              final cards = [
                _Metric(
                  label: 'Guests',
                  value: '${state.guests.length}',
                  detail: 'shared guest list',
                ),
                _Metric(
                  label: 'Tasks',
                  value: '${state.todos.length}',
                  detail: 'open planning items',
                ),
                _Metric(
                  label: 'Spent',
                  value: _money(spent),
                  detail: 'booked services',
                ),
                _Metric(label: 'Venue', value: '1', detail: state.location),
              ];
              return GridView.count(
                crossAxisCount: wide ? 4 : 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: wide ? 1.28 : 1.18,
                children: cards,
              );
            },
          ),
        ],
      ),
    );
  }
}

class _SharedPlanner extends ConsumerWidget {
  const _SharedPlanner();
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(plannerProvider);
    return _Page(
      title: 'Shared planning',
      eyebrow: 'Visible to bride and groom',
      child: Column(
        children: [
          _ListPanel(
            title: 'Guest list',
            icon: Icons.group_outlined,
            items: state.guests,
            onAdd: (value) =>
                ref.read(plannerProvider.notifier).addGuest(value),
          ),
          const SizedBox(height: 16),
          _ListPanel(
            title: 'Todo list',
            icon: Icons.checklist_rtl,
            items: state.todos,
            onAdd: (value) => ref.read(plannerProvider.notifier).addTodo(value),
          ),
          const SizedBox(height: 16),
          Card(
            child: ListTile(
              leading: const Icon(Icons.location_on_outlined),
              title: Text(state.location),
              subtitle: const Text('Shared wedding location'),
            ),
          ),
        ],
      ),
    );
  }
}

class _Marketplace extends ConsumerWidget {
  const _Marketplace();
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(plannerProvider);
    final role = state.user?.role;
    final visible = role == UserRole.bride
        ? state.vendors.where((vendor) => vendor.price <= state.budget).toList()
        : state.vendors;
    return _Page(
      title: role == UserRole.vendor
          ? 'Marketplace preview'
          : 'Vendor marketplace',
      eyebrow: role == UserRole.bride
          ? 'Curated services for your day'
          : 'Full service catalog',
      child: Column(
        children: visible.map((v) => _VendorCard(vendor: v)).toList(),
      ),
    );
  }
}

class _RoleRoom extends ConsumerWidget {
  const _RoleRoom();
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(plannerProvider);
    if (state.user!.role == UserRole.groom) return _GroomBudget(state: state);
    return _Page(
      title: 'Bride edit',
      eyebrow: 'Private bride workspace',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Bridal gowns, caterers, vendors, and locations are shown as a normal catalog experience.',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: 16),
          ...state.vendors
              .where(
                (v) =>
                    v.price <= state.budget &&
                    (v.category == 'Bridal gowns' || v.category == 'Catering'),
              )
              .map((v) => _VendorCard(vendor: v)),
        ],
      ),
    );
  }
}

class _GroomBudget extends ConsumerWidget {
  const _GroomBudget({required this.state});
  final PlannerState state;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return _Page(
      title: 'Budget control',
      eyebrow: 'Private groom workspace',
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(22),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _money(state.budget),
                style: Theme.of(context).textTheme.displayLarge,
              ),
              Text(
                'The bride never sees this number. It quietly determines which marketplace options are available in her catalog.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              Slider(
                value: state.budget.toDouble(),
                min: 1500000,
                max: 10000000,
                divisions: 17,
                label: _money(state.budget),
                onChanged: (v) =>
                    ref.read(plannerProvider.notifier).setBudget(v.round()),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _VendorStudio extends ConsumerWidget {
  const _VendorStudio();
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(plannerProvider);
    return _Page(
      title: 'Vendor studio',
      eyebrow: 'Service provider account',
      actions: [
        IconButton(
          onPressed: () => ref.read(plannerProvider.notifier).logout(),
          icon: const Icon(Icons.logout),
        ),
      ],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Publish services with images, pricing, category, and remarks. Couples discover approved services from the marketplace.',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: 16),
          ...state.vendors.take(2).map((v) => _VendorCard(vendor: v)),
        ],
      ),
    );
  }
}

class _HeroCopy extends StatelessWidget {
  const _HeroCopy({required this.onDemo});
  final ValueChanged<UserRole> onDemo;
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Hitched', style: Theme.of(context).textTheme.displayLarge),
        const SizedBox(height: 12),
        Text(
          'A private wedding planner for two people building one day together, with vendors invited into the same ecosystem.',
          style: Theme.of(context).textTheme.bodyLarge,
        ),
        const SizedBox(height: 22),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            OutlinedButton(
              onPressed: () => onDemo(UserRole.bride),
              child: const Text('View as bride'),
            ),
            OutlinedButton(
              onPressed: () => onDemo(UserRole.groom),
              child: const Text('View as groom'),
            ),
            OutlinedButton(
              onPressed: () => onDemo(UserRole.vendor),
              child: const Text('View as vendor'),
            ),
          ],
        ),
      ],
    ).animate().fadeIn(duration: 500.ms).slideY(begin: 0.08);
  }
}

class _WideHero extends StatelessWidget {
  const _WideHero({required this.state});
  final PlannerState state;
  @override
  Widget build(BuildContext context) {
    return Container(
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
                  'Wedding date',
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(color: Colors.white70),
                ),
                Text(
                  DateFormat.yMMMMd().format(DateTime.parse(state.weddingDate)),
                  style: Theme.of(
                    context,
                  ).textTheme.displayMedium?.copyWith(color: Colors.white),
                ),
                Text(
                  state.location,
                  style: const TextStyle(color: Colors.white70),
                ),
              ],
            ),
          ),
          const Icon(Icons.favorite, color: AppColors.champagne, size: 64),
        ],
      ),
    );
  }
}

class _Page extends StatelessWidget {
  const _Page({
    required this.title,
    required this.eyebrow,
    required this.child,
    this.actions = const [],
  });
  final String title;
  final String eyebrow;
  final Widget child;
  final List<Widget> actions;
  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverAppBar(
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(eyebrow, style: Theme.of(context).textTheme.bodyMedium),
              Text(title, style: Theme.of(context).textTheme.displayMedium),
            ],
          ),
          toolbarHeight: 88,
          actions: actions,
        ),
        SliverPadding(
          padding: const EdgeInsets.all(18),
          sliver: SliverToBoxAdapter(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 980),
              child: child
                  .animate()
                  .fadeIn(duration: 450.ms)
                  .slideY(begin: 0.03),
            ),
          ),
        ),
      ],
    );
  }
}

class _Metric extends StatelessWidget {
  const _Metric({
    required this.label,
    required this.value,
    required this.detail,
  });
  final String label;
  final String value;
  final String detail;
  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: Theme.of(context).textTheme.bodyMedium),
          const Spacer(),
          Text(value, style: Theme.of(context).textTheme.displayMedium),
          Text(detail, maxLines: 1, overflow: TextOverflow.ellipsis),
        ],
      ),
    ),
  );
}

class _VendorCard extends StatelessWidget {
  const _VendorCard({required this.vendor});
  final VendorItem vendor;
  @override
  Widget build(BuildContext context) => Card(
    margin: const EdgeInsets.only(bottom: 14),
    clipBehavior: Clip.antiAlias,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CachedNetworkImage(
          imageUrl: vendor.imageUrl,
          height: 170,
          width: double.infinity,
          fit: BoxFit.cover,
        ),
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      vendor.name,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ),
                  Chip(label: Text(vendor.category)),
                ],
              ),
              Text(vendor.description),
              const SizedBox(height: 8),
              Text(
                vendor.remarks,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 10),
              Text(
                _money(vendor.price),
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

class _ListPanel extends StatelessWidget {
  const _ListPanel({
    required this.title,
    required this.icon,
    required this.items,
    required this.onAdd,
  });
  final String title;
  final IconData icon;
  final List<String> items;
  final ValueChanged<String> onAdd;
  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon),
              const SizedBox(width: 10),
              Text(title, style: Theme.of(context).textTheme.titleLarge),
              const Spacer(),
              IconButton(
                onPressed: () => _dialog(context),
                icon: const Icon(Icons.add_circle_outline),
              ),
            ],
          ),
          ...items.map(
            (item) => ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(
                Icons.favorite,
                size: 16,
                color: AppColors.blush,
              ),
              title: Text(item),
            ),
          ),
        ],
      ),
    ),
  );
  void _dialog(BuildContext context) {
    final controller = TextEditingController();
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Add $title item'),
        content: TextField(controller: controller, autofocus: true),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (controller.text.trim().isNotEmpty) {
                onAdd(controller.text.trim());
              }
              Navigator.pop(context);
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }
}

class _Field extends StatelessWidget {
  const _Field({required this.controller, required this.label});
  final TextEditingController controller;
  final String label;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: TextField(
      controller: controller,
      decoration: InputDecoration(labelText: label),
    ),
  );
}

class _Atmosphere extends StatelessWidget {
  const _Atmosphere();
  @override
  Widget build(BuildContext context) => Container(
    decoration: const BoxDecoration(
      gradient: RadialGradient(
        center: Alignment(-0.9, -0.8),
        radius: 1.2,
        colors: [Color(0xFFFFE0CC), AppColors.ivory],
      ),
    ),
  );
}

String _roleLabel(UserRole role) => switch (role) {
  UserRole.bride => 'Bride',
  UserRole.groom => 'Groom',
  UserRole.vendor => 'Vendor',
};
String _money(int value) => NumberFormat.compactCurrency(
  symbol: 'NGN ',
  decimalDigits: 1,
).format(value / 100);
