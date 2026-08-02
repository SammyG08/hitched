import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/errors/api_exception.dart';
import '../../../shared/widgets/submit_button.dart';
import '../domain/budget_models.dart';
import 'budget_controller.dart';

class BudgetSetupScreen extends ConsumerStatefulWidget {
  const BudgetSetupScreen({super.key});

  @override
  ConsumerState<BudgetSetupScreen> createState() => _BudgetSetupScreenState();
}

class _BudgetSetupScreenState extends ConsumerState<BudgetSetupScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _amountController;
  late final TextEditingController _currencyController;
  late final bool _isEditing;

  @override
  void initState() {
    super.initState();
    final budget = ref.read(budgetProvider).value?.budget;
    _isEditing = budget != null;
    _amountController = TextEditingController(
      text: budget?.totalAmount.toStringAsFixed(2) ?? '',
    );
    _currencyController = TextEditingController(
      text: budget?.currency ?? 'USD',
    );
  }

  @override
  void dispose() {
    _amountController.dispose();
    _currencyController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final succeeded = await ref
        .read(budgetProvider.notifier)
        .saveBudget(
          BudgetDraft(
            totalAmount: double.parse(_amountController.text.trim()),
            currency: _currencyController.text,
          ),
        );
    if (succeeded && mounted) {
      context.pop();
      return;
    }
    if (mounted) _showError();
  }

  void _showError() {
    final error = ref.read(budgetProvider).value?.actionError;
    final message = error is ApiException
        ? error.displayMessage
        : error.toString();
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(budgetProvider).value;
    return Scaffold(
      appBar: AppBar(title: Text(_isEditing ? 'Edit budget' : 'Set up budget')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Start with the total amount you are comfortable spending. '
                  'You can change it later.',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const SizedBox(height: 24),
                TextFormField(
                  controller: _amountController,
                  autofocus: !_isEditing,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: const InputDecoration(
                    labelText: 'Total budget',
                    prefixIcon: Icon(Icons.account_balance_wallet_outlined),
                  ),
                  validator: (value) {
                    final amount = double.tryParse(value?.trim() ?? '');
                    return amount == null || amount < 0
                        ? 'Enter a valid non-negative amount.'
                        : null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _currencyController,
                  textCapitalization: TextCapitalization.characters,
                  maxLength: 3,
                  decoration: const InputDecoration(
                    labelText: 'Currency code',
                    hintText: 'USD',
                    prefixIcon: Icon(Icons.currency_exchange_rounded),
                  ),
                  validator: (value) {
                    final currency = value?.trim() ?? '';
                    return RegExp(r'^[A-Za-z]{3}$').hasMatch(currency)
                        ? null
                        : 'Use a three-letter code such as USD or GHS.';
                  },
                ),
                const SizedBox(height: 28),
                SubmitButton(
                  label: _isEditing ? 'Save budget' : 'Create budget',
                  isLoading: state?.isMutating ?? false,
                  onPressed: _submit,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
