import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hitched/core/theme/theme.dart';
import 'package:hitched/features/guests/data/guest_provider.dart';
import 'package:hitched/features/guests/data/guest_model.dart';
import 'package:http/http.dart' as http;

class GuestListScreen extends ConsumerWidget {
  const GuestListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final guestsAsync = ref.watch(guestListProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Guest List',
          style: Theme.of(context).textTheme.displayMedium,
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: guestsAsync.when(
        data: (guests) => ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: guests.length,
          itemBuilder: (context, index) {
            final guest = guests[index];
            return _buildGuestCard(context, guest);
          },
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddGuestDialog(context, ref),
        backgroundColor: AppColors.emerald,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildGuestCard(BuildContext context, Guest guest) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        title: Text(
          guest.name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(guest.email ?? 'No email'),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: _getStatusColor(guest.rsvpStatus).withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            guest.rsvpStatus.toUpperCase(),
            style: TextStyle(
              color: _getStatusColor(guest.rsvpStatus),
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'attending':
        return Colors.green;
      case 'declined':
        return Colors.red;
      default:
        return AppColors.textSecondary;
    }
  }

  void _showAddGuestDialog(BuildContext context, WidgetRef ref) {
    final nameController = TextEditingController();
    final emailController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Guest'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Name'),
            ),
            TextField(
              controller: emailController,
              decoration: const InputDecoration(labelText: 'Email'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final name = nameController.text;
              final email = emailController.text;
              if (name.isNotEmpty) {
                try {
                  final response = await http.post(
                    Uri.parse('http://localhost:8080/guests'),
                    headers: {'Content-Type': 'application/json'},
                    body: jsonEncode({'name': name, 'email': email}),
                  );
                  if (response.statusCode == 201) {
                    ref.invalidate(guestListProvider);
                    if (context.mounted) Navigator.pop(context);
                  }
                } catch (e) {
                  // Handle error
                }
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }
}
