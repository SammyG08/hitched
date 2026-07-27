import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hitched/core/models/wedding_models.dart';
import 'package:hitched/core/state/app_controller.dart';
import 'package:hitched/core/theme/theme.dart';
import 'package:hitched/core/widgets/hitched_widgets.dart';

class AuthScreen extends ConsumerStatefulWidget {
  const AuthScreen({super.key});

  @override
  ConsumerState<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends ConsumerState<AuthScreen> {
  int tab = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFFFF2E9), AppColors.ivory, Color(0xFFF7D6CC)],
          ),
        ),
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final wide = constraints.maxWidth >= 920;
              return SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 1160),
                    child: wide
                        ? Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              const Expanded(flex: 5, child: _AuthHero()),
                              const SizedBox(width: 28),
                              Expanded(
                                flex: 4,
                                child: _AuthCard(
                                  tab: tab,
                                  onTabChanged: (value) =>
                                      setState(() => tab = value),
                                ),
                              ),
                            ],
                          )
                        : Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              const _AuthHero(),
                              const SizedBox(height: 18),
                              _AuthCard(
                                tab: tab,
                                onTabChanged: (value) =>
                                    setState(() => tab = value),
                              ),
                            ],
                          ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _AuthHero extends StatelessWidget {
  const _AuthHero();

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 520),
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: AppColors.merlot,
        borderRadius: BorderRadius.circular(38),
        boxShadow: [
          BoxShadow(
            color: AppColors.merlot.withValues(alpha: 0.18),
            blurRadius: 50,
            offset: const Offset(0, 26),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          const _BrandMark(),
          const SizedBox(height: 86),
          Text(
            'Plan the wedding without losing the plot.',
            style: Theme.of(context).textTheme.displayLarge?.copyWith(
              color: Colors.white,
              fontSize: 58,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Shared guest lists, todos, bookings, and analytics for the couple. Private budget control for the groom. A real marketplace for vendors.',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: Colors.white.withValues(alpha: 0.82),
            ),
          ),
          const SizedBox(height: 28),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: const [
              _HeroBadge(icon: Icons.favorite_border, text: 'Couple workspace'),
              _HeroBadge(icon: Icons.lock_outline, text: 'Role privacy'),
              _HeroBadge(
                icon: Icons.storefront_outlined,
                text: 'Vendor booking',
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _AuthCard extends StatelessWidget {
  const _AuthCard({required this.tab, required this.onTabChanged});

  final int tab;
  final ValueChanged<int> onTabChanged;

  @override
  Widget build(BuildContext context) {
    final pages = [
      const _LoginForm(),
      const _CoupleRegisterForm(),
      const _VendorRegisterForm(),
    ];
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(22),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Welcome to Hitched',
              style: Theme.of(context).textTheme.displayMedium,
            ),
            const SizedBox(height: 6),
            Text(
              'Sign in or create the right account type.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 18),
            SegmentedButton<int>(
              segments: const [
                ButtonSegment(value: 0, label: Text('Login')),
                ButtonSegment(value: 1, label: Text('Couple')),
                ButtonSegment(value: 2, label: Text('Vendor')),
              ],
              selected: {tab},
              onSelectionChanged: (value) => onTabChanged(value.first),
            ),
            const SizedBox(height: 20),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 220),
              child: pages[tab],
            ),
          ],
        ),
      ),
    );
  }
}

class _LoginForm extends ConsumerStatefulWidget {
  const _LoginForm();

  @override
  ConsumerState<_LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends ConsumerState<_LoginForm> {
  final email = TextEditingController(text: 'bride@hitched.app');
  final password = TextEditingController(text: 'password123');

  @override
  Widget build(BuildContext context) {
    return Column(
      key: const ValueKey('login'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _AuthErrorBanner(),
        HitchedTextField(
          controller: email,
          label: 'Email',
          icon: Icons.alternate_email,
        ),
        HitchedTextField(
          controller: password,
          label: 'Password',
          icon: Icons.lock_outline,
          obscureText: true,
        ),
        const SizedBox(height: 8),
        ElevatedButton(
          onPressed: ref.watch(appControllerProvider).isBusy
              ? null
              : () async {
                  await ref
                      .read(appControllerProvider.notifier)
                      .login(email.text, password.text);
                },
          child: Text(
            ref.watch(appControllerProvider).isBusy ? 'Signing in...' : 'Login',
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'Use bride@hitched.app, groom@hitched.app, or vendor@hitched.app with any password.',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ],
    );
  }
}

class _CoupleRegisterForm extends ConsumerStatefulWidget {
  const _CoupleRegisterForm();

  @override
  ConsumerState<_CoupleRegisterForm> createState() =>
      _CoupleRegisterFormState();
}

class _CoupleRegisterFormState extends ConsumerState<_CoupleRegisterForm> {
  UserRole role = UserRole.bride;
  final name = TextEditingController(text: 'Amara Belle');
  final email = TextEditingController(text: 'bride@hitched.app');
  final password = TextEditingController(text: 'password123');
  final confirmPassword = TextEditingController(text: 'password123');
  final partnerName = TextEditingController(text: 'Daniel Hart');
  final partnerEmail = TextEditingController(text: 'groom@hitched.app');
  final partnerPassword = TextEditingController(text: 'password123');
  final confirmPartnerPassword = TextEditingController(text: 'password123');
  final date = TextEditingController(text: '2027-04-18');
  final location = TextEditingController(text: 'The Glasshouse, Lagos');

  @override
  Widget build(BuildContext context) {
    return Column(
      key: const ValueKey('couple'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _AuthErrorBanner(),
        SegmentedButton<UserRole>(
          segments: const [
            ButtonSegment(value: UserRole.bride, label: Text('Bride')),
            ButtonSegment(value: UserRole.groom, label: Text('Groom')),
          ],
          selected: {role},
          onSelectionChanged: (value) => setState(() => role = value.first),
        ),
        const SizedBox(height: 14),
        HitchedTextField(
          controller: name,
          label: 'Your full name',
          icon: Icons.person_outline,
        ),
        HitchedTextField(
          controller: email,
          label: 'Your email',
          icon: Icons.alternate_email,
        ),
        HitchedTextField(
          controller: password,
          label: 'Your password',
          icon: Icons.lock_outline,
          obscureText: true,
        ),
        HitchedTextField(
          controller: confirmPassword,
          label: 'Confirm your password',
          icon: Icons.verified_user_outlined,
          obscureText: true,
        ),
        HitchedTextField(
          controller: partnerName,
          label: role == UserRole.bride ? 'Groom name' : 'Bride name',
          icon: Icons.diversity_1_outlined,
        ),
        HitchedTextField(
          controller: partnerEmail,
          label: 'Partner email',
          icon: Icons.mark_email_unread_outlined,
        ),
        HitchedTextField(
          controller: partnerPassword,
          label: 'Partner password',
          icon: Icons.key_outlined,
          obscureText: true,
        ),
        HitchedTextField(
          controller: confirmPartnerPassword,
          label: 'Confirm partner password',
          icon: Icons.verified_user_outlined,
          obscureText: true,
        ),
        HitchedTextField(
          controller: date,
          label: 'Wedding date',
          icon: Icons.event_outlined,
        ),
        HitchedTextField(
          controller: location,
          label: 'Wedding location',
          icon: Icons.location_on_outlined,
        ),
        const SizedBox(height: 8),
        ElevatedButton(
          onPressed: ref.watch(appControllerProvider).isBusy
              ? null
              : () async {
                  if (password.text != confirmPassword.text) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Your passwords do not match'),
                      ),
                    );
                    return;
                  }
                  if (partnerPassword.text != confirmPartnerPassword.text) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Partner passwords do not match'),
                      ),
                    );
                    return;
                  }
                  await ref
                      .read(appControllerProvider.notifier)
                      .registerCouple(
                        role: role,
                        name: name.text,
                        email: email.text,
                        password: password.text,
                        partnerName: partnerName.text,
                        partnerEmail: partnerEmail.text,
                        partnerPassword: partnerPassword.text,
                        weddingDate: date.text,
                        location: location.text,
                      );
                },
          child: Text(
            ref.watch(appControllerProvider).isBusy
                ? 'Creating accounts...'
                : 'Create linked couple accounts',
          ),
        ),
      ],
    );
  }
}

class _VendorRegisterForm extends ConsumerStatefulWidget {
  const _VendorRegisterForm();

  @override
  ConsumerState<_VendorRegisterForm> createState() =>
      _VendorRegisterFormState();
}

class _VendorRegisterFormState extends ConsumerState<_VendorRegisterForm> {
  final owner = TextEditingController(text: 'Tara Studios');
  final email = TextEditingController(text: 'vendor@hitched.app');
  final password = TextEditingController(text: 'password123');
  final confirmPassword = TextEditingController(text: 'password123');
  final service = TextEditingController(text: 'Tara Studios');
  final price = TextEditingController(text: '3500000');
  VendorCategory category = VendorCategory.photography;

  @override
  Widget build(BuildContext context) {
    return Column(
      key: const ValueKey('vendor'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _AuthErrorBanner(),
        HitchedTextField(
          controller: owner,
          label: 'Owner name',
          icon: Icons.person_outline,
        ),
        HitchedTextField(
          controller: email,
          label: 'Business email',
          icon: Icons.alternate_email,
        ),
        HitchedTextField(
          controller: password,
          label: 'Password',
          icon: Icons.lock_outline,
          obscureText: true,
        ),
        HitchedTextField(
          controller: confirmPassword,
          label: 'Confirm password',
          icon: Icons.verified_user_outlined,
          obscureText: true,
        ),
        HitchedTextField(
          controller: service,
          label: 'Service name',
          icon: Icons.storefront_outlined,
        ),
        DropdownButtonFormField<VendorCategory>(
          // ignore: deprecated_member_use
          value: category,
          decoration: const InputDecoration(
            labelText: 'Category',
            prefixIcon: Icon(Icons.category_outlined),
          ),
          items: VendorCategory.values
              .map(
                (item) =>
                    DropdownMenuItem(value: item, child: Text(item.label)),
              )
              .toList(),
          onChanged: (value) => setState(() => category = value ?? category),
        ),
        const SizedBox(height: 12),
        HitchedTextField(
          controller: price,
          label: 'Starting price in NGN',
          icon: Icons.payments_outlined,
          keyboardType: TextInputType.number,
        ),
        const SizedBox(height: 8),
        ElevatedButton(
          onPressed: ref.watch(appControllerProvider).isBusy
              ? null
              : () async {
                  if (password.text != confirmPassword.text) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Passwords do not match')),
                    );
                    return;
                  }
                  await ref
                      .read(appControllerProvider.notifier)
                      .registerVendor(
                        ownerName: owner.text,
                        email: email.text,
                        password: password.text,
                        serviceName: service.text,
                        category: category,
                        startingPriceCents:
                            (int.tryParse(price.text) ?? 3500000) * 100,
                      );
                },
          child: Text(
            ref.watch(appControllerProvider).isBusy
                ? 'Creating vendor...'
                : 'Create vendor account',
          ),
        ),
      ],
    );
  }
}

class _BrandMark extends StatelessWidget {
  const _BrandMark();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
          ),
          child: const Icon(Icons.favorite, color: AppColors.merlot),
        ),
        const SizedBox(width: 12),
        Text(
          'Hitched',
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(color: Colors.white, fontSize: 30),
        ),
      ],
    );
  }
}

class _AuthErrorBanner extends ConsumerWidget {
  const _AuthErrorBanner();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final error = ref.watch(appControllerProvider).authError;
    if (error == null) return const SizedBox.shrink();
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.red.shade200),
      ),
      child: Text(error, style: TextStyle(color: Colors.red.shade800)),
    );
  }
}

class _HeroBadge extends StatelessWidget {
  const _HeroBadge({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.13),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.white24),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 16),
          const SizedBox(width: 8),
          Text(
            text,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}
