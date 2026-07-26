import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hitched/core/state/app_controller.dart';
import 'package:hitched/core/widgets/hitched_widgets.dart';
import 'package:hitched/features/marketplace/presentation/marketplace_screen.dart';

class VendorStudioScreen extends ConsumerWidget {
  const VendorStudioScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(appControllerProvider);
    final listings = state.visibleVendors;
    final inquiries = state.bookings
        .where(
          (booking) => listings.any((vendor) => vendor.id == booking.vendorId),
        )
        .length;
    return HitchedScaffold(
      title: 'Vendor studio',
      subtitle: 'Listings, inquiries, and booking pipeline',
      actions: [
        IconButton(
          onPressed: () => ref.read(appControllerProvider.notifier).logout(),
          icon: const Icon(Icons.logout),
        ),
      ],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          LayoutBuilder(
            builder: (context, box) {
              final wide = box.maxWidth > 720;
              return GridView.count(
                crossAxisCount: wide ? 3 : 1,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: wide ? 1.7 : 2.5,
                children: [
                  StatCard(
                    label: 'Listings',
                    value: '${listings.length}',
                    detail: 'published services',
                    icon: Icons.storefront_outlined,
                  ),
                  StatCard(
                    label: 'Inquiries',
                    value: '$inquiries',
                    detail: 'couple actions',
                    icon: Icons.mark_email_read_outlined,
                  ),
                  StatCard(
                    label: 'Rating',
                    value: listings.isEmpty
                        ? '-'
                        : listings.first.rating.toString(),
                    detail: 'average review score',
                    icon: Icons.star_outline,
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 16),
          Text('Your listings', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 10),
          if (listings.isEmpty)
            const EmptyState(
              title: 'No listing yet',
              message:
                  'Create a vendor account from registration to seed your first listing.',
              icon: Icons.storefront_outlined,
            )
          else
            ...listings.map(
              (vendor) => Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: SizedBox(height: 460, child: VendorCard(vendor: vendor)),
              ),
            ),
        ],
      ),
    );
  }
}
