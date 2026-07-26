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
        children: guests
            .map(
              (guest) => Card(
                child: ListTile(
                  leading: const Icon(Icons.person_outline),
                  title: Text(guest.name),
                  subtitle: Text(guest.email ?? 'No email added'),
                  trailing: Chip(label: Text(guest.status)),
                ),
              ),
            )
            .toList(),
      ),
    );
  }

  void _showAddGuest(BuildContext context, WidgetRef ref) {
    final name = TextEditingController();
    final email = TextEditingController();
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (context) => Padding(
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
            ElevatedButton(
              onPressed: () {
                ref
                    .read(appControllerProvider.notifier)
                    .addGuest(name.text, email.text);
                Navigator.pop(context);
              },
              child: const Text('Add guest'),
            ),
          ],
        ),
      ),
    );
  }
}
