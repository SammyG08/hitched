import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hitched/core/models/wedding_models.dart';
import 'package:hitched/core/state/app_controller.dart';
import 'package:hitched/core/widgets/hitched_widgets.dart';

class BookingsScreen extends ConsumerWidget {
  const BookingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(appControllerProvider);
    final controller = ref.read(appControllerProvider.notifier);
    final bookings = state.bookings;
    return HitchedScaffold(
      title: state.currentUser?.role == UserRole.vendor
          ? 'Inquiries'
          : 'Bookings',
      subtitle: 'Shortlists, requests, approvals, and confirmed services',
      child: bookings.isEmpty
          ? const EmptyState(
              title: 'No booking activity yet',
              message:
                  'Open the marketplace, shortlist a vendor, or request a booking.',
              icon: Icons.event_note_outlined,
            )
          : Column(
              children: bookings.map((booking) {
                final vendor = state.vendors.firstWhere(
                  (item) => item.id == booking.vendorId,
                );
                final package = vendor.packages.firstWhere(
                  (item) => item.id == booking.packageId,
                );
                final isVendor = state.currentUser?.role == UserRole.vendor;
                return Card(
                  child: Padding(
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
                            Chip(label: Text(booking.status.label)),
                          ],
                        ),
                        Text('${package.name} ? ${money(package.priceCents)}'),
                        const SizedBox(height: 8),
                        Text(booking.note),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            if (isVendor &&
                                booking.status == BookingStatus.requested)
                              ElevatedButton(
                                onPressed: () => controller.updateBookingStatus(
                                  booking.id,
                                  BookingStatus.accepted,
                                ),
                                child: const Text('Accept'),
                              ),
                            if (isVendor &&
                                booking.status == BookingStatus.requested)
                              OutlinedButton(
                                onPressed: () => controller.updateBookingStatus(
                                  booking.id,
                                  BookingStatus.declined,
                                ),
                                child: const Text('Decline'),
                              ),
                            if (!isVendor &&
                                booking.status == BookingStatus.accepted)
                              ElevatedButton(
                                onPressed: () => controller.updateBookingStatus(
                                  booking.id,
                                  BookingStatus.booked,
                                ),
                                child: const Text('Confirm booking'),
                              ),
                            if (!isVendor &&
                                booking.status == BookingStatus.shortlisted)
                              OutlinedButton(
                                onPressed: () => controller.updateBookingStatus(
                                  booking.id,
                                  BookingStatus.requested,
                                ),
                                child: const Text('Request now'),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
    );
  }
}
