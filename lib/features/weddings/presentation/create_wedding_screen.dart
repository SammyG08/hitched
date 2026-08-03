import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/errors/api_exception.dart';
import '../../../shared/widgets/progress_stepper.dart';
import '../../../shared/widgets/submit_button.dart';
import 'wedding_workspace_controller.dart';

class CreateWeddingScreen extends ConsumerStatefulWidget {
  const CreateWeddingScreen({super.key});

  @override
  ConsumerState<CreateWeddingScreen> createState() =>
      _CreateWeddingScreenState();
}

class _CreateWeddingScreenState extends ConsumerState<CreateWeddingScreen> {
  final _nameKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _locationController = TextEditingController();
  DateTime? _weddingDate;
  var _step = 0;

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

  void _continue() {
    if (_step == 0 && !_nameKey.currentState!.validate()) return;
    setState(() => _step++);
  }

  Future<void> _submit() async {
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
    final isCreating =
        ref.watch(weddingWorkspaceProvider).value?.isCreating ?? false;
    return Scaffold(
      appBar: AppBar(title: const Text('Create your wedding')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 520),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(_title, style: Theme.of(context).textTheme.displaySmall),
                  const SizedBox(height: 8),
                  Text(_subtitle, style: Theme.of(context).textTheme.bodyLarge),
                  const SizedBox(height: 26),
                  ProgressStepper(
                    currentStep: _step,
                    labels: const ['The two of you', 'When & where', 'Review'],
                  ),
                  const SizedBox(height: 26),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 280),
                    child: switch (_step) {
                      0 => _nameStep(),
                      1 => _detailsStep(),
                      _ => _reviewStep(isCreating),
                    },
                  ),
                  if (_step > 0 && !isCreating) ...[
                    const SizedBox(height: 10),
                    TextButton.icon(
                      onPressed: () => setState(() => _step--),
                      icon: const Icon(Icons.arrow_back_rounded),
                      label: const Text('Back'),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  String get _title => switch (_step) {
    0 => 'What shall we call it?',
    1 => 'Set the scene',
    _ => 'Your day is taking shape',
  };

  String get _subtitle => switch (_step) {
    0 => 'Give your shared planning space a name.',
    1 => 'Add the date and place—or leave either for later.',
    _ => 'Review the details before creating your workspace.',
  };

  Widget _nameStep() => Form(
    key: _nameKey,
    child: Column(
      key: const ValueKey('wedding-name'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextFormField(
          controller: _nameController,
          autofocus: true,
          textCapitalization: TextCapitalization.words,
          textInputAction: TextInputAction.done,
          onFieldSubmitted: (_) => _continue(),
          decoration: const InputDecoration(
            labelText: 'Wedding name',
            hintText: 'Alex & Jamie',
            prefixIcon: Icon(Icons.favorite_outline_rounded),
          ),
          validator: (value) => value == null || value.trim().isEmpty
              ? 'Enter a wedding name.'
              : null,
        ),
        const SizedBox(height: 22),
        FilledButton.icon(
          onPressed: _continue,
          icon: const Icon(Icons.arrow_forward_rounded),
          label: const Text('Continue'),
        ),
      ],
    ),
  );

  Widget _detailsStep() => Column(
    key: const ValueKey('wedding-details'),
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      TextField(
        controller: _locationController,
        autofocus: true,
        textCapitalization: TextCapitalization.words,
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
            _weddingDate == null ? 'Choose later' : _displayDate(_weddingDate!),
          ),
        ),
      ),
      const SizedBox(height: 22),
      FilledButton.icon(
        onPressed: _continue,
        icon: const Icon(Icons.arrow_forward_rounded),
        label: const Text('Review wedding'),
      ),
    ],
  );

  Widget _reviewStep(bool isCreating) => Column(
    key: const ValueKey('wedding-review'),
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      Card(
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Image.asset(
              'assets/images/wedding_table_hero.png',
              height: 150,
              fit: BoxFit.cover,
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _nameController.text.trim(),
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    _locationController.text.trim().isEmpty
                        ? 'Location to be decided'
                        : _locationController.text.trim(),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _weddingDate == null
                        ? 'Date to be decided'
                        : _displayDate(_weddingDate!),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      const SizedBox(height: 22),
      SubmitButton(
        label: 'Create wedding',
        isLoading: isCreating,
        onPressed: _submit,
      ),
    ],
  );

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
