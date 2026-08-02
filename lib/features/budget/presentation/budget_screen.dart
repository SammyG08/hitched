import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/errors/api_exception.dart';
import '../../weddings/presentation/wedding_workspace_controller.dart';
import '../domain/budget_models.dart';
import 'budget_controller.dart';

class BudgetScreen extends ConsumerWidget {
  const BudgetScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(budgetProvider);
    final weddingName = ref
        .watch(weddingWorkspaceProvider)
        .value
        ?.selectedWedding
        ?.name;

    return Scaffold(
      appBar: AppBar(
        title: Text(weddingName == null ? 'Budget' : '$weddingName budget'),
      ),
      body: state.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, _) => _BudgetError(
          onRetry: () => ref.read(budgetProvider.notifier).refresh(),
        ),
        data: (data) => data.budget == null
            ? _UnconfiguredBudget(vendorCount: data.vendors.length)
            : _BudgetBody(state: data),
      ),
    );
  }
}

class _UnconfiguredBudget extends StatelessWidget {
  const _UnconfiguredBudget({required this.vendorCount});

  final int vendorCount;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.account_balance_wallet_outlined, size: 72),
            const SizedBox(height: 20),
            Text(
              'Plan the money, protect the joy.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 10),
            Text(
              'Set a total budget, allocate categories, and track every '
              'expense and payment${vendorCount == 0 ? '.' : ' against your vendors.'}',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: () => context.push('/budget/setup'),
              icon: const Icon(Icons.add_rounded),
              label: const Text('Set up budget'),
            ),
          ],
        ),
      ),
    );
  }
}

class _BudgetBody extends ConsumerWidget {
  const _BudgetBody({required this.state});

  final BudgetState state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final budget = state.budget!;
    final expenses = state.visibleExpenses;
    return RefreshIndicator(
      onRefresh: () => ref.read(budgetProvider.notifier).refresh(),
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(child: _BudgetHealthCard(budget: budget)),
          SliverToBoxAdapter(
            child: _SectionHeading(
              title: 'Allocations',
              actionLabel: 'Add category',
              onAction: () => context.push('/budget/categories/new'),
            ),
          ),
          if (state.categories.isEmpty)
            const SliverToBoxAdapter(
              child: _EmptySection(
                message:
                    'Split the budget into categories such as Venue or Catering.',
              ),
            )
          else
            SliverToBoxAdapter(
              child: SizedBox(
                height: 172,
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  scrollDirection: Axis.horizontal,
                  itemCount: state.categories.length,
                  separatorBuilder: (_, _) => const SizedBox(width: 10),
                  itemBuilder: (_, index) => _CategoryCard(
                    category: state.categories[index],
                    currency: budget.currency,
                  ),
                ),
              ),
            ),
          SliverToBoxAdapter(
            child: _SectionHeading(
              title: 'Expenses',
              actionLabel: 'Add expense',
              onAction: state.categories.isEmpty
                  ? null
                  : () => context.push('/budget/expenses/new'),
            ),
          ),
          SliverToBoxAdapter(child: _ExpenseFilters(state: state)),
          if (expenses.isEmpty)
            const SliverToBoxAdapter(
              child: _EmptySection(message: 'No expenses match this view.'),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 96),
              sliver: SliverList.builder(
                itemCount: expenses.length,
                itemBuilder: (_, index) => _ExpenseCard(
                  expense: expenses[index],
                  currency: budget.currency,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _BudgetHealthCard extends StatelessWidget {
  const _BudgetHealthCard({required this.budget});

  final WeddingBudget budget;

  @override
  Widget build(BuildContext context) {
    final overBudget = budget.remainingAmount < 0;
    return Card(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Total budget',
                        style: Theme.of(context).textTheme.labelLarge,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _money(budget.totalAmount, budget.currency),
                        style: Theme.of(context).textTheme.headlineMedium
                            ?.copyWith(fontWeight: FontWeight.w800),
                      ),
                    ],
                  ),
                ),
                IconButton.filledTonal(
                  tooltip: 'Edit budget',
                  onPressed: () => context.push('/budget/setup'),
                  icon: const Icon(Icons.edit_outlined),
                ),
              ],
            ),
            const SizedBox(height: 16),
            LinearProgressIndicator(
              value: budget.spentProgress,
              color: overBudget ? Colors.red : null,
              minHeight: 8,
              borderRadius: BorderRadius.circular(8),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _HealthValue(
                    label: 'Actual',
                    value: _money(budget.actualTotal, budget.currency),
                  ),
                ),
                Expanded(
                  child: _HealthValue(
                    label: overBudget ? 'Over budget' : 'Remaining',
                    value: _money(
                      budget.remainingAmount.abs(),
                      budget.currency,
                    ),
                    color: overBudget ? Colors.red : null,
                  ),
                ),
                Expanded(
                  child: _HealthValue(
                    label: 'Outstanding',
                    value: _money(budget.outstandingAmount, budget.currency),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _HealthValue extends StatelessWidget {
  const _HealthValue({required this.label, required this.value, this.color});

  final String label;
  final String value;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: Theme.of(context).textTheme.bodySmall),
        const SizedBox(height: 3),
        Text(
          value,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(fontWeight: FontWeight.w700, color: color),
        ),
      ],
    );
  }
}

class _SectionHeading extends StatelessWidget {
  const _SectionHeading({
    required this.title,
    required this.actionLabel,
    required this.onAction,
  });

  final String title;
  final String actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 12, 10),
      child: Row(
        children: [
          Expanded(
            child: Text(title, style: Theme.of(context).textTheme.titleLarge),
          ),
          TextButton.icon(
            onPressed: onAction,
            icon: const Icon(Icons.add_rounded),
            label: Text(actionLabel),
          ),
        ],
      ),
    );
  }
}

class _CategoryCard extends ConsumerWidget {
  const _CategoryCard({required this.category, required this.currency});

  final BudgetCategory category;
  final String currency;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final over = category.remainingAmount < 0;
    return SizedBox(
      width: 210,
      child: Card(
        margin: EdgeInsets.zero,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () => context.push('/budget/categories/${category.id}/edit'),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        category.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                    ),
                    PopupMenuButton<String>(
                      padding: EdgeInsets.zero,
                      onSelected: (value) {
                        if (value == 'edit') {
                          context.push(
                            '/budget/categories/${category.id}/edit',
                          );
                        } else {
                          _deleteCategory(context, ref);
                        }
                      },
                      itemBuilder: (_) => const [
                        PopupMenuItem(value: 'edit', child: Text('Edit')),
                        PopupMenuItem(value: 'delete', child: Text('Delete')),
                      ],
                    ),
                  ],
                ),
                const Spacer(),
                Text(
                  '${_money(category.actualTotal, currency)} of '
                  '${_money(category.allocatedAmount, currency)}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: 8),
                LinearProgressIndicator(
                  value: category.spentProgress,
                  color: over ? Colors.red : null,
                  borderRadius: BorderRadius.circular(6),
                ),
                const SizedBox(height: 7),
                Text(
                  over
                      ? '${_money(category.remainingAmount.abs(), currency)} over'
                      : '${_money(category.remainingAmount, currency)} left',
                  style: TextStyle(
                    fontSize: 12,
                    color: over ? Colors.red : null,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _deleteCategory(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete category?'),
        content: Text(
          'Deleting ${category.name} also deletes every expense in it.',
        ),
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
    );
    if (confirmed != true) return;
    final succeeded = await ref
        .read(budgetProvider.notifier)
        .deleteCategory(category.id);
    if (!succeeded && context.mounted) _showBudgetError(context, ref);
  }
}

class _ExpenseFilters extends ConsumerWidget {
  const _ExpenseFilters({required this.state});

  final BudgetState state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      child: Column(
        children: [
          TextField(
            onChanged: ref.read(budgetProvider.notifier).setQuery,
            decoration: const InputDecoration(
              hintText: 'Search expenses or vendors',
              prefixIcon: Icon(Icons.search_rounded),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<int?>(
                  initialValue: state.categoryFilter,
                  decoration: const InputDecoration(labelText: 'Category'),
                  items: [
                    const DropdownMenuItem<int?>(
                      value: null,
                      child: Text('All categories'),
                    ),
                    ...state.categories.map(
                      (category) => DropdownMenuItem<int?>(
                        value: category.id,
                        child: Text(category.name),
                      ),
                    ),
                  ],
                  onChanged: ref
                      .read(budgetProvider.notifier)
                      .setCategoryFilter,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: DropdownButtonFormField<ExpensePaymentStatus?>(
                  initialValue: state.paymentFilter,
                  decoration: const InputDecoration(labelText: 'Payment'),
                  items: [
                    const DropdownMenuItem<ExpensePaymentStatus?>(
                      value: null,
                      child: Text('All payments'),
                    ),
                    ...ExpensePaymentStatus.values.map(
                      (status) => DropdownMenuItem<ExpensePaymentStatus?>(
                        value: status,
                        child: Text(status.label),
                      ),
                    ),
                  ],
                  onChanged: ref.read(budgetProvider.notifier).setPaymentFilter,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ExpenseCard extends ConsumerWidget {
  const _ExpenseCard({required this.expense, required this.currency});

  final BudgetExpense expense;
  final String currency;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => context.push('/budget/expenses/${expense.id}/edit'),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 8, 14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      expense.name,
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      [
                        expense.categoryName,
                        if (expense.displayVendorName.isNotEmpty)
                          expense.displayVendorName,
                      ].join(' • '),
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    const SizedBox(height: 9),
                    Wrap(
                      spacing: 8,
                      runSpacing: 6,
                      children: [
                        _ExpenseBadge(
                          icon: Icons.payments_outlined,
                          label: _money(expense.actualAmount, currency),
                        ),
                        _ExpenseBadge(
                          icon: _paymentIcon(expense.paymentStatus),
                          label: expense.paymentStatus.label,
                          color: _paymentColor(expense.paymentStatus),
                        ),
                        if (expense.dueDate != null)
                          _ExpenseBadge(
                            icon: Icons.event_outlined,
                            label: expense.isOverdue
                                ? 'Overdue ${_shortDate(expense.dueDate!)}'
                                : 'Due ${_shortDate(expense.dueDate!)}',
                            color: expense.isOverdue ? Colors.red : null,
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              PopupMenuButton<String>(
                onSelected: (value) {
                  if (value == 'edit') {
                    context.push('/budget/expenses/${expense.id}/edit');
                  } else if (value == 'payment') {
                    _recordPayment(context, ref);
                  } else {
                    _deleteExpense(context, ref);
                  }
                },
                itemBuilder: (_) => [
                  const PopupMenuItem(value: 'edit', child: Text('Edit')),
                  if (expense.paymentStatus != ExpensePaymentStatus.paid)
                    const PopupMenuItem(
                      value: 'payment',
                      child: Text('Record payment'),
                    ),
                  const PopupMenuItem(value: 'delete', child: Text('Delete')),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _recordPayment(BuildContext context, WidgetRef ref) async {
    final controller = TextEditingController(
      text: expense.amountPaid.toStringAsFixed(2),
    );
    final formKey = GlobalKey<FormState>();
    final newTotal = await showDialog<double>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Record payment'),
        content: Form(
          key: formKey,
          child: TextFormField(
            controller: controller,
            autofocus: true,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(
              labelText: 'Total paid to date',
              helperText: 'Maximum ${_money(expense.actualAmount, currency)}',
            ),
            validator: (value) {
              final amount = double.tryParse(value?.trim() ?? '');
              if (amount == null || amount < 0) return 'Enter a valid amount.';
              if (amount > expense.actualAmount) {
                return 'Paid cannot exceed the actual amount.';
              }
              return null;
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              if (!formKey.currentState!.validate()) return;
              Navigator.pop(context, double.parse(controller.text.trim()));
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
    controller.dispose();
    if (newTotal == null) return;
    final succeeded = await ref
        .read(budgetProvider.notifier)
        .recordPayment(expense.id, newTotal);
    if (!succeeded && context.mounted) _showBudgetError(context, ref);
  }

  Future<void> _deleteExpense(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete expense?'),
        content: Text('${expense.name} will be permanently removed.'),
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
    );
    if (confirmed != true) return;
    final succeeded = await ref
        .read(budgetProvider.notifier)
        .deleteExpense(expense.id);
    if (!succeeded && context.mounted) _showBudgetError(context, ref);
  }
}

class _ExpenseBadge extends StatelessWidget {
  const _ExpenseBadge({required this.icon, required this.label, this.color});

  final IconData icon;
  final String label;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: color),
        const SizedBox(width: 4),
        Text(label, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }
}

class _EmptySection extends StatelessWidget {
  const _EmptySection({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: Text(message, textAlign: TextAlign.center),
    );
  }
}

class _BudgetError extends StatelessWidget {
  const _BudgetError({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('Budget could not be loaded.'),
          const SizedBox(height: 12),
          OutlinedButton(onPressed: onRetry, child: const Text('Try again')),
        ],
      ),
    );
  }
}

void _showBudgetError(BuildContext context, WidgetRef ref) {
  final error = ref.read(budgetProvider).value?.actionError;
  final message = error is ApiException
      ? error.displayMessage
      : error.toString();
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
}

String _money(double amount, String currency) {
  return '$currency ${amount.toStringAsFixed(2)}';
}

String _shortDate(DateTime date) {
  const months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];
  return '${months[date.month - 1]} ${date.day}';
}

IconData _paymentIcon(ExpensePaymentStatus status) {
  return switch (status) {
    ExpensePaymentStatus.unpaid => Icons.money_off_csred_outlined,
    ExpensePaymentStatus.partiallyPaid => Icons.timelapse_rounded,
    ExpensePaymentStatus.paid => Icons.check_circle_outline_rounded,
  };
}

Color _paymentColor(ExpensePaymentStatus status) {
  return switch (status) {
    ExpensePaymentStatus.unpaid => Colors.red,
    ExpensePaymentStatus.partiallyPaid => Colors.orange,
    ExpensePaymentStatus.paid => Colors.green,
  };
}
