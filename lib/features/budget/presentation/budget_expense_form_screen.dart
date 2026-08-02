import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/errors/api_exception.dart';
import '../../../shared/widgets/submit_button.dart';
import '../domain/budget_models.dart';
import 'budget_controller.dart';

class BudgetExpenseFormScreen extends ConsumerStatefulWidget {
  const BudgetExpenseFormScreen({this.expenseId, super.key});

  final int? expenseId;

  @override
  ConsumerState<BudgetExpenseFormScreen> createState() =>
      _BudgetExpenseFormScreenState();
}

class _BudgetExpenseFormScreenState
    extends ConsumerState<BudgetExpenseFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _vendorNameController;
  late final TextEditingController _estimatedController;
  late final TextEditingController _actualController;
  late final TextEditingController _paidController;
  late final TextEditingController _notesController;
  int? _categoryId;
  int? _vendorId;
  DateTime? _dueDate;

  bool get _isEditing => widget.expenseId != null;

  @override
  void initState() {
    super.initState();
    final budgetState = ref.read(budgetProvider).value;
    final expense = widget.expenseId == null
        ? null
        : budgetState?.expenses
              .where((item) => item.id == widget.expenseId)
              .firstOrNull;
    _categoryId =
        expense?.categoryId ?? budgetState?.categories.firstOrNull?.id;
    _vendorId = expense?.vendor?.id;
    _dueDate = expense?.dueDate;
    _nameController = TextEditingController(text: expense?.name ?? '');
    _vendorNameController = TextEditingController(
      text: expense?.vendorName ?? '',
    );
    _estimatedController = TextEditingController(
      text: expense?.estimatedAmount.toStringAsFixed(2) ?? '0.00',
    );
    _actualController = TextEditingController(
      text: expense?.actualAmount.toStringAsFixed(2) ?? '0.00',
    );
    _paidController = TextEditingController(
      text: expense?.amountPaid.toStringAsFixed(2) ?? '0.00',
    );
    _notesController = TextEditingController(text: expense?.notes ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _vendorNameController.dispose();
    _estimatedController.dispose();
    _actualController.dispose();
    _paidController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _chooseDate() async {
    final now = DateTime.now();
    final date = await showDatePicker(
      context: context,
      initialDate: _dueDate ?? now,
      firstDate: DateTime(now.year - 2),
      lastDate: DateTime(now.year + 10),
    );
    if (date != null) setState(() => _dueDate = date);
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate() || _categoryId == null) return;
    final succeeded = await ref
        .read(budgetProvider.notifier)
        .saveExpense(
          expenseId: widget.expenseId,
          draft: BudgetExpenseDraft(
            categoryId: _categoryId!,
            name: _nameController.text,
            vendorId: _vendorId,
            vendorName: _vendorNameController.text,
            estimatedAmount: double.parse(_estimatedController.text.trim()),
            actualAmount: double.parse(_actualController.text.trim()),
            amountPaid: double.parse(_paidController.text.trim()),
            dueDate: _dueDate,
            notes: _notesController.text,
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

  String? _amountValidator(String? value) {
    final amount = double.tryParse(value?.trim() ?? '');
    return amount == null || amount < 0 ? 'Enter a valid amount.' : null;
  }

  String? _paidValidator(String? value) {
    final baseError = _amountValidator(value);
    if (baseError != null) return baseError;
    final paid = double.parse(value!.trim());
    final actual = double.tryParse(_actualController.text.trim()) ?? 0;
    return actual > 0 && paid > actual
        ? 'Paid cannot exceed actual cost.'
        : null;
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(budgetProvider).value;
    final currency = state?.budget?.currency ?? '';
    final categories = state?.categories ?? const <BudgetCategory>[];
    final vendors = state?.vendors ?? const <BudgetVendor>[];
    return Scaffold(
      appBar: AppBar(title: Text(_isEditing ? 'Edit expense' : 'Add expense')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                DropdownButtonFormField<int>(
                  initialValue: _categoryId,
                  decoration: const InputDecoration(
                    labelText: 'Category',
                    prefixIcon: Icon(Icons.category_outlined),
                  ),
                  items: categories
                      .map(
                        (category) => DropdownMenuItem(
                          value: category.id,
                          child: Text(category.name),
                        ),
                      )
                      .toList(),
                  onChanged: (value) => setState(() => _categoryId = value),
                  validator: (value) =>
                      value == null ? 'Choose a category.' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _nameController,
                  autofocus: !_isEditing,
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(
                    labelText: 'Expense name',
                    hintText: 'Venue deposit',
                    prefixIcon: Icon(Icons.receipt_long_outlined),
                  ),
                  validator: (value) => value == null || value.trim().isEmpty
                      ? 'Enter an expense name.'
                      : null,
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<int?>(
                  initialValue: _vendorId,
                  decoration: const InputDecoration(
                    labelText: 'Linked vendor',
                    prefixIcon: Icon(Icons.storefront_outlined),
                  ),
                  items: [
                    const DropdownMenuItem<int?>(
                      value: null,
                      child: Text('No linked vendor'),
                    ),
                    ...vendors.map(
                      (vendor) => DropdownMenuItem<int?>(
                        value: vendor.id,
                        child: Text(
                          vendor.serviceCategory.isEmpty
                              ? vendor.name
                              : '${vendor.name} (${vendor.serviceCategory})',
                        ),
                      ),
                    ),
                  ],
                  onChanged: (value) => setState(() => _vendorId = value),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _vendorNameController,
                  decoration: const InputDecoration(
                    labelText: 'Unlisted vendor name',
                    helperText:
                        'Use this when the vendor is not in Hitched yet.',
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _estimatedController,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        decoration: InputDecoration(
                          labelText: 'Estimated',
                          prefixText: currency.isEmpty ? null : '$currency ',
                        ),
                        validator: _amountValidator,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextFormField(
                        controller: _actualController,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        decoration: InputDecoration(
                          labelText: 'Actual',
                          prefixText: currency.isEmpty ? null : '$currency ',
                        ),
                        validator: _amountValidator,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _paidController,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: InputDecoration(
                    labelText: 'Amount paid to date',
                    prefixText: currency.isEmpty ? null : '$currency ',
                    helperText: 'Hitched calculates the payment status.',
                  ),
                  validator: _paidValidator,
                ),
                const SizedBox(height: 16),
                InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: _chooseDate,
                  child: InputDecorator(
                    decoration: InputDecoration(
                      labelText: 'Payment due date',
                      prefixIcon: const Icon(Icons.event_outlined),
                      suffixIcon: _dueDate == null
                          ? null
                          : IconButton(
                              tooltip: 'Clear date',
                              onPressed: () => setState(() => _dueDate = null),
                              icon: const Icon(Icons.close_rounded),
                            ),
                    ),
                    child: Text(
                      _dueDate == null
                          ? 'No due date'
                          : _displayDate(_dueDate!),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _notesController,
                  minLines: 3,
                  maxLines: 5,
                  decoration: const InputDecoration(
                    labelText: 'Notes',
                    alignLabelWithHint: true,
                  ),
                ),
                const SizedBox(height: 28),
                SubmitButton(
                  label: _isEditing ? 'Save expense' : 'Create expense',
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
