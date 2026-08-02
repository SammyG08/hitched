import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/errors/api_exception.dart';
import '../../../shared/widgets/submit_button.dart';
import 'wedding_workspace_controller.dart';

class WeddingSettingsScreen extends ConsumerStatefulWidget {
  const WeddingSettingsScreen({super.key});

  @override
  ConsumerState<WeddingSettingsScreen> createState() =>
      _WeddingSettingsScreenState();
}

class _WeddingSettingsScreenState extends ConsumerState<WeddingSettingsScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _locationController;
  DateTime? _weddingDate;

  @override
  void initState() {
    super.initState();
    final wedding = ref.read(weddingWorkspaceProvider).value?.selectedWedding;
    _nameController = TextEditingController(text: wedding?.name ?? '');
    _locationController = TextEditingController(text: wedding?.location ?? '');
    _weddingDate = wedding?.weddingDate;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  Future<void> _chooseDate() async {
    final now = DateTime.now();
    final date = await showDatePicker(
      context: context,
      initialDate: _weddingDate ?? now.add(const Duration(days: 180)),
      firstDate: DateTime(now.year - 5),
      lastDate: DateTime(now.year + 15),
    );
    if (date != null) setState(() => _weddingDate = date);
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final succeeded = await ref
        .read(weddingWorkspaceProvider.notifier)
        .updateSelectedWedding(
          name: _nameController.text,
          location: _locationController.text,
          weddingDate: _weddingDate,
        );
    if (succeeded && mounted) {
      context.pop();
      return;
    }
    if (mounted) _showError();
  }

  Future<void> _delete(String weddingName) async {
    final confirmationController = TextEditingController();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Delete this wedding?'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'This permanently removes the wedding and all of its tasks, '
                'guests, budget, vendors, schedule, and invitations.',
              ),
              const SizedBox(height: 16),
              Text('Type “$weddingName” to confirm.'),
              const SizedBox(height: 10),
              TextField(
                controller: confirmationController,
                autofocus: true,
                onChanged: (_) => setDialogState(() {}),
                decoration: const InputDecoration(labelText: 'Wedding name'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Keep wedding'),
            ),
            FilledButton(
              onPressed: confirmationController.text == weddingName
                  ? () => Navigator.pop(context, true)
                  : null,
              child: const Text('Delete permanently'),
            ),
          ],
        ),
      ),
    );
    confirmationController.dispose();
    if (confirmed != true) return;
    final succeeded = await ref
        .read(weddingWorkspaceProvider.notifier)
        .deleteSelectedWedding();
    if (succeeded && mounted) {
      context.go('/home');
      return;
    }
    if (mounted) _showError();
  }

  void _showError() {
    final error = ref.read(weddingWorkspaceProvider).value?.actionError;
    final message = error is ApiException
        ? error.displayMessage
        : error.toString();
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final workspace = ref.watch(weddingWorkspaceProvider).value;
    final wedding = workspace?.selectedWedding;
    if (wedding == null) {
      return const Scaffold(body: Center(child: Text('No wedding selected.')));
    }
    return Scaffold(
      appBar: AppBar(title: const Text('Wedding settings')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Wedding details',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 8),
                Text(
                  wedding.isOwner
                      ? 'Keep the shared workspace details current.'
                      : 'As a partner, you can keep these shared details current.',
                ),
                const SizedBox(height: 24),
                TextFormField(
                  controller: _nameController,
                  autofocus: false,
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(
                    labelText: 'Wedding name',
                    prefixIcon: Icon(Icons.favorite_outline_rounded),
                  ),
                  validator: (value) => value == null || value.trim().isEmpty
                      ? 'Enter a wedding name.'
                      : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _locationController,
                  decoration: const InputDecoration(
                    labelText: 'Location',
                    prefixIcon: Icon(Icons.location_on_outlined),
                  ),
                ),
                const SizedBox(height: 16),
                InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: _chooseDate,
                  child: InputDecorator(
                    decoration: InputDecoration(
                      labelText: 'Wedding date',
                      prefixIcon: const Icon(Icons.calendar_month_outlined),
                      suffixIcon: _weddingDate == null
                          ? null
                          : IconButton(
                              tooltip: 'Clear date',
                              onPressed: () =>
                                  setState(() => _weddingDate = null),
                              icon: const Icon(Icons.close_rounded),
                            ),
                    ),
                    child: Text(
                      _weddingDate == null
                          ? 'Choose later'
                          : _displayDate(_weddingDate!),
                    ),
                  ),
                ),
                const SizedBox(height: 28),
                SubmitButton(
                  label: 'Save wedding',
                  isLoading: workspace?.isCreating ?? false,
                  onPressed: _save,
                ),
                if (wedding.isOwner) ...[
                  const SizedBox(height: 42),
                  Divider(color: Theme.of(context).colorScheme.errorContainer),
                  const SizedBox(height: 20),
                  Text(
                    'Danger zone',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Deleting a wedding cannot be undone. Every related record '
                    'will be permanently removed.',
                  ),
                  const SizedBox(height: 16),
                  OutlinedButton.icon(
                    onPressed: workspace?.isCreating == true
                        ? null
                        : () => _delete(wedding.name),
                    icon: const Icon(Icons.delete_forever_outlined),
                    label: const Text('Delete wedding'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Theme.of(context).colorScheme.error,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

String _displayDate(DateTime date) {
  const months = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];
  return '${months[date.month - 1]} ${date.day}, ${date.year}';
}
