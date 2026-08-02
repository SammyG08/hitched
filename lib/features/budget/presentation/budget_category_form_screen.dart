import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/errors/api_exception.dart';
import '../../../shared/widgets/submit_button.dart';
import '../domain/budget_models.dart';
import 'budget_controller.dart';

class BudgetCategoryFormScreen extends ConsumerStatefulWidget {
  const BudgetCategoryFormScreen({this.categoryId, super.key});

  final int? categoryId;

  @override
  ConsumerState<BudgetCategoryFormScreen> createState() =>
      _BudgetCategoryFormScreenState();
}

class _BudgetCategoryFormScreenState
    extends ConsumerState<BudgetCategoryFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _amountController;

  bool get _isEditing => widget.categoryId != null;

  @override
  void initState() {
    super.initState();
    final category = widget.categoryId == null
        ? null
        : ref
              .read(budgetProvider)
              .value
              ?.categories
              .where((item) => item.id == widget.categoryId)
              .firstOrNull;
    _nameController = TextEditingController(text: category?.name ?? '');
    _amountController = TextEditingController(
      text: category?.allocatedAmount.toStringAsFixed(2) ?? '',
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final succeeded = await ref
        .read(budgetProvider.notifier)
        .saveCategory(
          categoryId: widget.categoryId,
          draft: BudgetCategoryDraft(
            name: _nameController.text,
            allocatedAmount: double.parse(_amountController.text.trim()),
          ),
        );
    if (succeeded && mounted) {
      context.pop();
      return;
    }
    if (mounted) {
      final error = ref.read(budgetProvider).value?.actionError;
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
    final state = ref.watch(budgetProvider).value;
    final currency = state?.budget?.currency ?? '';
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit category' : 'Add category'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextFormField(
                  controller: _nameController,
                  autofocus: !_isEditing,
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(
                    labelText: 'Category name',
                    hintText: 'Venue, Catering, Photography...',
                    prefixIcon: Icon(Icons.category_outlined),
                  ),
                  validator: (value) => value == null || value.trim().isEmpty
                      ? 'Enter a category name.'
                      : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _amountController,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: InputDecoration(
                    labelText: 'Allocated amount',
                    prefixText: currency.isEmpty ? null : '$currency ',
                  ),
                  validator: (value) {
                    final amount = double.tryParse(value?.trim() ?? '');
                    return amount == null || amount < 0
                        ? 'Enter a valid non-negative amount.'
                        : null;
                  },
                ),
                const SizedBox(height: 28),
                SubmitButton(
                  label: _isEditing ? 'Save category' : 'Create category',
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
