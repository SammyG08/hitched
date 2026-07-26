import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hitched/core/models/wedding_models.dart';
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
          onPressed: () => _showCreateListing(context, ref),
          icon: const Icon(Icons.add_business_outlined),
        ),
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

  void _showCreateListing(BuildContext context, WidgetRef ref) {
    final name = TextEditingController();
    final city = TextEditingController(text: 'Lagos');
    final description = TextEditingController();
    final imageUrl = TextEditingController();
    final price = TextEditingController(text: '3000000');
    final packageName = TextEditingController(text: 'Signature package');
    final packageDescription = TextEditingController();
    var category = VendorCategory.photography;

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (context) => StatefulBuilder(
        builder: (context, setSheetState) => Padding(
          padding: EdgeInsets.fromLTRB(
            18,
            18,
            18,
            MediaQuery.of(context).viewInsets.bottom + 18,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Create vendor listing',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 12),
                HitchedTextField(
                  controller: name,
                  label: 'Listing name',
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
                        (item) => DropdownMenuItem(
                          value: item,
                          child: Text(item.label),
                        ),
                      )
                      .toList(),
                  onChanged: (value) =>
                      setSheetState(() => category = value ?? category),
                ),
                const SizedBox(height: 12),
                HitchedTextField(
                  controller: city,
                  label: 'City',
                  icon: Icons.location_city_outlined,
                ),
                HitchedTextField(
                  controller: description,
                  label: 'Description',
                  icon: Icons.notes_outlined,
                ),
                HitchedTextField(
                  controller: imageUrl,
                  label: 'Image URL',
                  icon: Icons.image_outlined,
                ),
                HitchedTextField(
                  controller: price,
                  label: 'Starting price in NGN',
                  icon: Icons.payments_outlined,
                  keyboardType: TextInputType.number,
                ),
                HitchedTextField(
                  controller: packageName,
                  label: 'Package name',
                  icon: Icons.inventory_2_outlined,
                ),
                HitchedTextField(
                  controller: packageDescription,
                  label: 'Package description',
                  icon: Icons.description_outlined,
                ),
                ElevatedButton(
                  onPressed: () {
                    ref
                        .read(appControllerProvider.notifier)
                        .createVendorListing(
                          name: name.text.trim().isEmpty
                              ? 'Untitled service'
                              : name.text.trim(),
                          category: category,
                          city: city.text.trim().isEmpty
                              ? 'Lagos'
                              : city.text.trim(),
                          description: description.text.trim().isEmpty
                              ? 'Premium wedding service available for booking.'
                              : description.text.trim(),
                          imageUrl: imageUrl.text.trim(),
                          startingPriceCents:
                              (int.tryParse(price.text) ?? 3000000) * 100,
                          packageName: packageName.text.trim().isEmpty
                              ? 'Signature package'
                              : packageName.text.trim(),
                          packageDescription:
                              packageDescription.text.trim().isEmpty
                              ? 'Core service package for one wedding day.'
                              : packageDescription.text.trim(),
                        );
                    Navigator.pop(context);
                  },
                  child: const Text('Publish listing'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
