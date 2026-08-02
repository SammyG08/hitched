import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/errors/api_exception.dart';
import '../../weddings/presentation/wedding_workspace_controller.dart';
import '../domain/vendor_models.dart';
import 'vendor_controller.dart';

class VendorListScreen extends ConsumerWidget {
  const VendorListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final vendorState = ref.watch(vendorListProvider);
    final weddingName = ref
        .watch(weddingWorkspaceProvider)
        .value
        ?.selectedWedding
        ?.name;
    return Scaffold(
      appBar: AppBar(
        title: Text(weddingName == null ? 'Vendors' : '$weddingName vendors'),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/vendors/new'),
        icon: const Icon(Icons.add_rounded),
        label: const Text('Vendor'),
      ),
      body: vendorState.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, _) => _VendorError(
          onRetry: () => ref.read(vendorListProvider.notifier).refresh(),
        ),
        data: (data) => _VendorListBody(state: data),
      ),
    );
  }
}

class _VendorListBody extends ConsumerWidget {
  const _VendorListBody({required this.state});

  final VendorListState state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final vendors = state.visibleVendors;
    return RefreshIndicator(
      onRefresh: () => ref.read(vendorListProvider.notifier).refresh(),
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(child: _VendorSummary(state: state)),
          SliverToBoxAdapter(child: _VendorFilters(state: state)),
          if (vendors.isEmpty)
            const SliverFillRemaining(
              hasScrollBody: false,
              child: _EmptyVendors(),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 96),
              sliver: SliverList.builder(
                itemCount: vendors.length,
                itemBuilder: (_, index) => _VendorCard(vendor: vendors[index]),
              ),
            ),
        ],
      ),
    );
  }
}

class _VendorSummary extends StatelessWidget {
  const _VendorSummary({required this.state});

  final VendorListState state;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 12),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Row(
          children: [
            Expanded(
              child: _SummaryValue(
                label: 'Vendors',
                value: state.vendors.length.toString(),
              ),
            ),
            Expanded(
              child: _SummaryValue(
                label: 'Booked',
                value: state.bookedCount.toString(),
              ),
            ),
            Expanded(
              child: _SummaryValue(
                label: 'Signed',
                value: state.signedCount.toString(),
              ),
            ),
            Expanded(
              child: _SummaryValue(
                label: 'Quoted',
                value: _number(state.quotedTotal),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryValue extends StatelessWidget {
  const _SummaryValue({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 3),
        Text(label, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }
}

class _VendorFilters extends ConsumerWidget {
  const _VendorFilters({required this.state});

  final VendorListState state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: Column(
        children: [
          TextField(
            onChanged: ref.read(vendorListProvider.notifier).setQuery,
            decoration: const InputDecoration(
              hintText: 'Search vendors or contacts',
              prefixIcon: Icon(Icons.search_rounded),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<VendorServiceCategory?>(
                  initialValue: state.categoryFilter,
                  decoration: const InputDecoration(labelText: 'Service'),
                  items: [
                    const DropdownMenuItem<VendorServiceCategory?>(
                      value: null,
                      child: Text('All services'),
                    ),
                    ...VendorServiceCategory.values.map(
                      (category) => DropdownMenuItem<VendorServiceCategory?>(
                        value: category,
                        child: Text(category.label),
                      ),
                    ),
                  ],
                  onChanged: ref
                      .read(vendorListProvider.notifier)
                      .setCategoryFilter,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: DropdownButtonFormField<VendorBookingStatus?>(
                  initialValue: state.bookingFilter,
                  decoration: const InputDecoration(labelText: 'Booking'),
                  items: [
                    const DropdownMenuItem<VendorBookingStatus?>(
                      value: null,
                      child: Text('All bookings'),
                    ),
                    ...VendorBookingStatus.values.map(
                      (status) => DropdownMenuItem<VendorBookingStatus?>(
                        value: status,
                        child: Text(status.label),
                      ),
                    ),
                  ],
                  onChanged: ref
                      .read(vendorListProvider.notifier)
                      .setBookingFilter,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                ChoiceChip(
                  label: const Text('All contracts'),
                  selected: state.contractFilter == null,
                  onSelected: (_) => ref
                      .read(vendorListProvider.notifier)
                      .setContractFilter(null),
                ),
                for (final status in VendorContractStatus.values) ...[
                  const SizedBox(width: 8),
                  ChoiceChip(
                    label: Text(status.label),
                    selected: state.contractFilter == status,
                    onSelected: (_) => ref
                        .read(vendorListProvider.notifier)
                        .setContractFilter(status),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _VendorCard extends ConsumerWidget {
  const _VendorCard({required this.vendor});

  final WeddingVendor vendor;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => context.push('/vendors/${vendor.id}/edit'),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 8, 14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(child: Icon(_categoryIcon(vendor.serviceCategory))),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      vendor.name,
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      vendor.serviceCategory.label,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    if (vendor.contactPerson.isNotEmpty ||
                        vendor.email.isNotEmpty ||
                        vendor.phone.isNotEmpty) ...[
                      const SizedBox(height: 9),
                      Text(
                        [
                          if (vendor.contactPerson.isNotEmpty)
                            vendor.contactPerson,
                          if (vendor.email.isNotEmpty) vendor.email,
                          if (vendor.phone.isNotEmpty) vendor.phone,
                        ].join(' • '),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 6,
                      children: [
                        _VendorBadge(
                          icon: Icons.bookmark_outline_rounded,
                          label: vendor.bookingStatus.label,
                          color: _bookingColor(vendor.bookingStatus),
                        ),
                        _VendorBadge(
                          icon: Icons.request_quote_outlined,
                          label: vendor.quoteAmount == null
                              ? vendor.quoteStatus.label
                              : 'Quote ${_number(vendor.quoteAmount!)}',
                        ),
                        _VendorBadge(
                          icon: Icons.description_outlined,
                          label: vendor.contractStatus.label,
                          color:
                              vendor.contractStatus ==
                                  VendorContractStatus.signed
                              ? Colors.green
                              : null,
                        ),
                      ],
                    ),
                    if (vendor.actualExpenseTotal > 0) ...[
                      const SizedBox(height: 10),
                      Text(
                        'Expenses ${_number(vendor.actualExpenseTotal)} • '
                        '${_number(vendor.outstandingExpenseTotal)} outstanding',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ],
                ),
              ),
              PopupMenuButton<String>(
                onSelected: (value) => _handleAction(context, ref, value),
                itemBuilder: (_) => [
                  const PopupMenuItem(value: 'edit', child: Text('Edit')),
                  if (vendor.bookingStatus != VendorBookingStatus.booked)
                    const PopupMenuItem(
                      value: 'book',
                      child: Text('Mark booked'),
                    ),
                  if (vendor.contractStatus != VendorContractStatus.signed)
                    const PopupMenuItem(
                      value: 'sign',
                      child: Text('Mark contract signed'),
                    ),
                  const PopupMenuItem(value: 'delete', child: Text('Delete')),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _handleAction(
    BuildContext context,
    WidgetRef ref,
    String action,
  ) async {
    if (action == 'edit') {
      context.push('/vendors/${vendor.id}/edit');
      return;
    }
    if (action == 'delete') {
      await _confirmDelete(context, ref);
      return;
    }
    final succeeded = await ref
        .read(vendorListProvider.notifier)
        .updateWorkflow(
          vendor.id,
          bookingStatus: action == 'book' ? VendorBookingStatus.booked : null,
          contractStatus: action == 'sign' ? VendorContractStatus.signed : null,
        );
    if (!succeeded && context.mounted) _showVendorError(context, ref);
  }

  Future<void> _confirmDelete(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete vendor?'),
        content: Text(
          '${vendor.name} will be removed. Linked expenses are kept but '
          'will no longer reference this vendor.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    final succeeded = await ref
        .read(vendorListProvider.notifier)
        .deleteVendor(vendor.id);
    if (!succeeded && context.mounted) _showVendorError(context, ref);
  }
}

class _VendorBadge extends StatelessWidget {
  const _VendorBadge({required this.icon, required this.label, this.color});

  final IconData icon;
  final String label;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: color),
        const SizedBox(width: 4),
        Text(label, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }
}

class _EmptyVendors extends StatelessWidget {
  const _EmptyVendors();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.storefront_outlined, size: 64),
            SizedBox(height: 16),
            Text('No vendors match this view.'),
          ],
        ),
      ),
    );
  }
}

class _VendorError extends StatelessWidget {
  const _VendorError({required this.onRetry});
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('Vendors could not be loaded.'),
          const SizedBox(height: 12),
          OutlinedButton(onPressed: onRetry, child: const Text('Try again')),
        ],
      ),
    );
  }
}

void _showVendorError(BuildContext context, WidgetRef ref) {
  final error = ref.read(vendorListProvider).value?.actionError;
  final message = error is ApiException
      ? error.displayMessage
      : error.toString();
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
}

String _number(double value) => value.toStringAsFixed(2);

Color _bookingColor(VendorBookingStatus status) {
  return switch (status) {
    VendorBookingStatus.researching => Colors.blueGrey,
    VendorBookingStatus.contacted => Colors.blue,
    VendorBookingStatus.shortlisted => Colors.orange,
    VendorBookingStatus.booked => Colors.green,
    VendorBookingStatus.rejected => Colors.red,
  };
}

IconData _categoryIcon(VendorServiceCategory category) {
  return switch (category) {
    VendorServiceCategory.venue => Icons.location_city_outlined,
    VendorServiceCategory.catering => Icons.restaurant_outlined,
    VendorServiceCategory.photography => Icons.photo_camera_outlined,
    VendorServiceCategory.videography => Icons.videocam_outlined,
    VendorServiceCategory.floral => Icons.local_florist_outlined,
    VendorServiceCategory.entertainment => Icons.music_note_outlined,
    VendorServiceCategory.attire => Icons.checkroom_outlined,
    VendorServiceCategory.beauty => Icons.face_retouching_natural_outlined,
    VendorServiceCategory.transportation => Icons.directions_car_outlined,
    VendorServiceCategory.stationery => Icons.mail_outline_rounded,
    VendorServiceCategory.cake => Icons.cake_outlined,
    VendorServiceCategory.planning => Icons.event_note_outlined,
    VendorServiceCategory.other => Icons.storefront_outlined,
  };
}
