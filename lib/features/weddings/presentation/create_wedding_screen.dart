import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/errors/api_exception.dart';
import '../../../shared/widgets/submit_button.dart';
import 'wedding_workspace_controller.dart';

class CreateWeddingScreen extends ConsumerStatefulWidget {
  const CreateWeddingScreen({super.key});

  @override
  ConsumerState<CreateWeddingScreen> createState() =>
      _CreateWeddingScreenState();
}

class _CreateWeddingScreenState extends ConsumerState<CreateWeddingScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _locationController = TextEditingController();
  DateTime? _weddingDate;

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
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 10),
    );
    if (date != null) setState(() => _weddingDate = date);
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final succeeded = await ref
        .read(weddingWorkspaceProvider.notifier)
        .createWedding(
          name: _nameController.text,
          location: _locationController.text,
          weddingDate: _weddingDate,
        );
    if (succeeded && mounted) {
      context.pop();
      return;
    }
    if (mounted) {
      final error = ref.read(weddingWorkspaceProvider).requireValue.actionError;
      final message = error is ApiException
          ? error.displayMessage
          : error.toString();
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final workspace = ref.watch(weddingWorkspaceProvider).value;
    final isCreating = workspace?.isCreating ?? false;

    return Scaffold(
      appBar: AppBar(title: const Text('Create a wedding')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Your shared workspace',
                  style: Theme.of(context).textTheme.displaySmall,
                ),
                const SizedBox(height: 8),
                Text(
                  'These details become the home for your plans. You can change them later.',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const SizedBox(height: 28),
                TextFormField(
                  controller: _nameController,
                  autofocus: true,
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(
                    labelText: 'Wedding name',
                    hintText: 'Alex & Jamie',
                    prefixIcon: Icon(Icons.favorite_outline_rounded),
                  ),
                  validator: (value) => value == null || value.trim().isEmpty
                      ? 'Enter a wedding name.'
                      : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _locationController,
                  textInputAction: TextInputAction.done,
                  decoration: const InputDecoration(
                    labelText: 'Location',
                    hintText: 'Accra',
                    prefixIcon: Icon(Icons.location_on_outlined),
                  ),
                ),
                const SizedBox(height: 16),
                InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: _chooseDate,
                  child: InputDecorator(
                    decoration: const InputDecoration(
                      labelText: 'Wedding date',
                      prefixIcon: Icon(Icons.calendar_month_outlined),
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
                  label: 'Create wedding',
                  isLoading: isCreating,
                  onPressed: _submit,
                ),
              ],
            ),
          ),
        ),
      ),
    );
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
}
