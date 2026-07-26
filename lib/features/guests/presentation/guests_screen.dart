import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hitched/core/state/app_controller.dart';
import 'package:hitched/core/widgets/hitched_widgets.dart';

class GuestsScreen extends ConsumerWidget {
  const GuestsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final guests = ref.watch(appControllerProvider).guests;
    return HitchedScaffold(
      title: 'Guest list',
      subtitle: 'Shared couple workspace',
      actions: [
        IconButton(
          onPressed: () => _showAddGuest(context, ref),
          icon: const Icon(Icons.add),
        ),
      ],
      child: Column(
        children: guests.map((guest) {
          return Dismissible(
            key: ValueKey(guest.id),
            direction: DismissDirection.endToStart,
            background: Container(
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.only(right: 18),
              decoration: BoxDecoration(
                color: Colors.red.shade700,
                borderRadius: BorderRadius.circular(24),
              ),
              child: const Icon(Icons.delete_outline, color: Colors.white),
            ),
            onDismissed: (_) =>
                ref.read(appControllerProvider.notifier).removeGuest(guest.id),
            child: Card(
              child: ListTile(
                leading: const Icon(Icons.person_outline),
                title: Text(guest.name),
                subtitle: Text(guest.email ?? 'No email added'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Chip(label: Text(guest.status)),
                    IconButton(
                      tooltip: 'Remove guest',
                      onPressed: () => ref
                          .read(appControllerProvider.notifier)
                          .removeGuest(guest.id),
                      icon: const Icon(Icons.delete_outline),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  void _showAddGuest(BuildContext context, WidgetRef ref) {
    final name = TextEditingController();
    final email = TextEditingController();
    var status = 'pending';
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
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Add guest', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 12),
              HitchedTextField(
                controller: name,
                label: 'Guest name',
                icon: Icons.person_outline,
              ),
              HitchedTextField(
                controller: email,
                label: 'Email',
                icon: Icons.alternate_email,
              ),
              SegmentedButton<String>(
                segments: const [
                  ButtonSegment(value: 'pending', label: Text('Pending')),
                  ButtonSegment(value: 'attending', label: Text('Attending')),
                  ButtonSegment(value: 'declined', label: Text('Declined')),
                ],
                selected: {status},
                onSelectionChanged: (value) =>
                    setSheetState(() => status = value.first),
              ),
              const SizedBox(height: 12),
              Text(
                'Pending means the guest is invited but has not confirmed their RSVP yet.',
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: () {
                  ref
                      .read(appControllerProvider.notifier)
                      .addGuestWithStatus(name.text, email.text, status);
                  Navigator.pop(context);
                },
                child: const Text('Add guest'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
