import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hitched/core/models/wedding_models.dart';
import 'package:hitched/core/state/app_controller.dart';
import 'package:hitched/core/theme/theme.dart';
import 'package:hitched/core/widgets/hitched_widgets.dart';

class MarketplaceScreen extends ConsumerWidget {
  const MarketplaceScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(appControllerProvider);
    final vendors = state.visibleVendors;
    return HitchedScaffold(
      title: 'Vendor marketplace',
      subtitle: state.currentUser?.role == UserRole.bride
          ? 'Curated for your celebration'
          : 'Browse and manage services',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: const Text('All'),
                    selected: state.selectedCategory == null,
                    onSelected: (_) => ref
                        .read(appControllerProvider.notifier)
                        .selectCategory(null),
                  ),
                ),
                ...VendorCategory.values.map(
                  (category) => Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(category.label),
                      selected: state.selectedCategory == category,
                      onSelected: (_) => ref
                          .read(appControllerProvider.notifier)
                          .selectCategory(category),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          if (vendors.isEmpty)
            const EmptyState(
              title: 'No vendors found',
              message:
                  'Try another category or ask the groom to review private budget rules.',
              icon: Icons.storefront_outlined,
            )
          else
            LayoutBuilder(
              builder: (context, box) {
                final wide = box.maxWidth > 760;
                return GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: vendors.length,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: wide ? 2 : 1,
                    mainAxisSpacing: 14,
                    crossAxisSpacing: 14,
                    childAspectRatio: wide ? 0.92 : 0.86,
                  ),
                  itemBuilder: (context, index) =>
                      VendorCard(vendor: vendors[index]),
                );
              },
            ),
        ],
      ),
    );
  }
}

class VendorCard extends ConsumerWidget {
  const VendorCard({super.key, required this.vendor});

  final VendorListing vendor;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bookings = ref.watch(appControllerProvider).bookings;
    final booking = bookings
        .where((item) => item.vendorId == vendor.id)
        .firstOrNull;
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => VendorDetailScreen(vendor: vendor)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: CachedNetworkImage(
                imageUrl: vendor.imageUrl,
                width: double.infinity,
                fit: BoxFit.cover,
                errorWidget: (_, __, ___) => Container(
                  color: AppColors.champagne,
                  child: const Icon(Icons.image_not_supported_outlined),
                ),
              ),
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
                      Text('? ${vendor.rating}'),
                    ],
                  ),
                  Text(
                    '${vendor.category.label} ? ${vendor.city}',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    vendor.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Text(
                        'from ${money(vendor.startingPriceCents)}',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const Spacer(),
                      if (booking != null)
                        Chip(label: Text(booking.status.label))
                      else
                        const Icon(Icons.chevron_right),
                    ],
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

class VendorDetailScreen extends ConsumerStatefulWidget {
  const VendorDetailScreen({super.key, required this.vendor});

  final VendorListing vendor;

  @override
  ConsumerState<VendorDetailScreen> createState() => _VendorDetailScreenState();
}

class _VendorDetailScreenState extends ConsumerState<VendorDetailScreen> {
  late String packageId = widget.vendor.packages.first.id;
  final note = TextEditingController(
    text: 'We love your style and want to check availability.',
  );

  @override
  Widget build(BuildContext context) {
    final vendor = widget.vendor;
    return HitchedScaffold(
      title: vendor.name,
      subtitle: '${vendor.category.label} ? ${vendor.city}',
      actions: [
        IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.close),
        ),
      ],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(30),
            child: CachedNetworkImage(
              imageUrl: vendor.imageUrl,
              height: 260,
              width: double.infinity,
              fit: BoxFit.cover,
              errorWidget: (_, __, ___) =>
                  Container(height: 260, color: AppColors.champagne),
            ),
          ),
          const SizedBox(height: 18),
          Text(
            vendor.description,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: 18),
          Text('Packages', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 10),
          ...vendor.packages.map(
            (package) => RadioListTile<String>(
              value: package.id,
              // ignore: deprecated_member_use
              groupValue: packageId,
              // ignore: deprecated_member_use
              onChanged: (value) =>
                  setState(() => packageId = value ?? packageId),
              title: Text('${package.name} - ${money(package.priceCents)}'),
              subtitle: Text(package.description),
            ),
          ),
          const SizedBox(height: 12),
          HitchedTextField(
            controller: note,
            label: 'Booking note',
            icon: Icons.notes_outlined,
          ),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => ref
                      .read(appControllerProvider.notifier)
                      .shortlistVendor(vendor.id),
                  child: const Text('Shortlist'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => ref
                      .read(appControllerProvider.notifier)
                      .requestBooking(vendor.id, packageId, note.text),
                  child: const Text('Request booking'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Text('Reviews', style: Theme.of(context).textTheme.titleLarge),
          ...vendor.reviews.map(
            (review) => Card(
              child: ListTile(
                title: Text('${review.author} ? ${review.rating} stars'),
                subtitle: Text(review.comment),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
