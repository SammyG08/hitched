import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/errors/api_exception.dart';
import '../domain/guest_models.dart';
import 'guest_controller.dart';

class GuestListScreen extends ConsumerWidget {
  const GuestListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(guestListProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Guests')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/guests/households/new'),
        icon: const Icon(Icons.add_home_outlined),
        label: const Text('Household'),
      ),
      body: state.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => _GuestError(
          onRetry: () => ref.read(guestListProvider.notifier).refresh(),
        ),
        data: (data) => _GuestListBody(state: data),
      ),
    );
  }
}

class _GuestListBody extends ConsumerWidget {
  const _GuestListBody({required this.state});

  final GuestListState state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final households = state.visibleHouseholds;
    final attending = state.guests
        .where((guest) => guest.rsvpStatus == GuestRsvpStatus.attending)
        .length;
    return RefreshIndicator(
      onRefresh: () => ref.read(guestListProvider.notifier).refresh(),
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
        children: [
          Row(
            children: [
              Expanded(
                child: _SummaryCard(
                  label: 'Total guests',
                  value: state.guests.length.toString(),
                  icon: Icons.groups_2_outlined,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _SummaryCard(
                  label: 'Attending',
                  value: attending.toString(),
                  icon: Icons.check_circle_outline_rounded,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          TextField(
            onChanged: ref.read(guestListProvider.notifier).setQuery,
            decoration: const InputDecoration(
              hintText: 'Search households or guests',
              prefixIcon: Icon(Icons.search_rounded),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<InvitationStatus?>(
                  initialValue: state.invitationFilter,
                  decoration: const InputDecoration(labelText: 'Invitation'),
                  items: [
                    const DropdownMenuItem(value: null, child: Text('All')),
                    ...InvitationStatus.values.map(
                      (status) => DropdownMenuItem(
                        value: status,
                        child: Text(status.label),
                      ),
                    ),
                  ],
                  onChanged: ref
                      .read(guestListProvider.notifier)
                      .setInvitationFilter,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: DropdownButtonFormField<GuestRsvpStatus?>(
                  initialValue: state.rsvpFilter,
                  decoration: const InputDecoration(labelText: 'RSVP'),
                  items: [
                    const DropdownMenuItem(value: null, child: Text('All')),
                    ...GuestRsvpStatus.values.map(
                      (status) => DropdownMenuItem(
                        value: status,
                        child: Text(status.label),
                      ),
                    ),
                  ],
                  onChanged: ref.read(guestListProvider.notifier).setRsvpFilter,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (households.isEmpty)
            const _EmptyGuests()
          else
            for (final household in households)
              _HouseholdCard(
                household: household,
                guests: state.guestsFor(household.id),
              ),
        ],
      ),
    );
  }
}

class _HouseholdCard extends ConsumerWidget {
  const _HouseholdCard({required this.household, required this.guests});

  final GuestHousehold household;
  final List<WeddingGuest> guests;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ExpansionTile(
        initiallyExpanded: true,
        leading: CircleAvatar(child: Text(household.guestCount.toString())),
        title: Text(
          household.name,
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
        subtitle: Text(
          '${household.attendingCount} attending · ${household.invitationStatus.label}',
        ),
        childrenPadding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton.icon(
                onPressed: () =>
                    context.push('/guests/new?householdId=${household.id}'),
                icon: const Icon(Icons.person_add_alt_rounded),
                label: const Text('Guest'),
              ),
              PopupMenuButton<String>(
                onSelected: (action) async {
                  if (action == 'edit') {
                    context.push('/guests/households/${household.id}/edit');
                  } else if (action == 'delete') {
                    await _deleteHousehold(context, ref);
                  }
                },
                itemBuilder: (_) => const [
                  PopupMenuItem(value: 'edit', child: Text('Edit household')),
                  PopupMenuItem(
                    value: 'delete',
                    child: Text('Delete household'),
                  ),
                ],
              ),
            ],
          ),
          if (guests.isEmpty)
            const Padding(
              padding: EdgeInsets.all(12),
              child: Text('No guests in this household.'),
            )
          else
            for (final guest in guests) _GuestTile(guest: guest),
        ],
      ),
    );
  }

  Future<void> _deleteHousehold(BuildContext context, WidgetRef ref) async {
    final confirmed = await _confirm(
      context,
      'Delete household?',
      'This also deletes every guest and plus-one in ${household.name}.',
    );
    if (!confirmed) return;
    final succeeded = await ref
        .read(guestListProvider.notifier)
        .deleteHousehold(household.id);
    if (!succeeded && context.mounted) _showError(context, ref);
  }
}

class _GuestTile extends ConsumerWidget {
  const _GuestTile({required this.guest});

  final WeddingGuest guest;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: CircleAvatar(
        child: Icon(
          guest.isPlusOne ? Icons.person_add_outlined : Icons.person_outline,
        ),
      ),
      title: Text(guest.fullName),
      subtitle: Text(
        [
          if (guest.isPlusOne) 'Plus-one',
          if (guest.tableName.isNotEmpty) guest.tableName,
          if (guest.dietaryRequirements.isNotEmpty) 'Dietary notes',
        ].join(' · '),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          PopupMenuButton<GuestRsvpStatus>(
            tooltip: 'Update RSVP',
            onSelected: (status) async {
              final succeeded = await ref
                  .read(guestListProvider.notifier)
                  .updateRsvp(guest.id, status);
              if (!succeeded && context.mounted) _showError(context, ref);
            },
            itemBuilder: (_) => GuestRsvpStatus.values
                .map(
                  (status) =>
                      PopupMenuItem(value: status, child: Text(status.label)),
                )
                .toList(),
            child: Chip(
              label: Text(guest.rsvpStatus.label),
              visualDensity: VisualDensity.compact,
            ),
          ),
          PopupMenuButton<String>(
            onSelected: (action) async {
              if (action == 'edit') {
                context.push('/guests/${guest.id}/edit');
              } else if (action == 'delete') {
                await _deleteGuest(context, ref);
              }
            },
            itemBuilder: (_) => const [
              PopupMenuItem(value: 'edit', child: Text('Edit')),
              PopupMenuItem(value: 'delete', child: Text('Delete')),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _deleteGuest(BuildContext context, WidgetRef ref) async {
    final confirmed = await _confirm(
      context,
      'Delete guest?',
      '${guest.fullName} will be permanently removed.',
    );
    if (!confirmed) return;
    final succeeded = await ref
        .read(guestListProvider.notifier)
        .deleteGuest(guest.id);
    if (!succeeded && context.mounted) _showError(context, ref);
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(icon, color: Theme.of(context).colorScheme.primary),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(value, style: Theme.of(context).textTheme.headlineSmall),
                Text(label),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyGuests extends StatelessWidget {
  const _EmptyGuests();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.all(32),
      child: Column(
        children: [
          Icon(Icons.groups_2_outlined, size: 64),
          SizedBox(height: 16),
          Text('No households match this view.'),
        ],
      ),
    );
  }
}

class _GuestError extends StatelessWidget {
  const _GuestError({required this.onRetry});
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: OutlinedButton(
        onPressed: onRetry,
        child: const Text('Retry guests'),
      ),
    );
  }
}

Future<bool> _confirm(
  BuildContext context,
  String title,
  String message,
) async {
  return await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(title),
          content: Text(message),
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
      ) ??
      false;
}

void _showError(BuildContext context, WidgetRef ref) {
  final error = ref.read(guestListProvider).value?.actionError;
  final message = error is ApiException
      ? error.displayMessage
      : error.toString();
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
}
