import 'package:hitched/features/budget/domain/budget_models.dart';
import 'package:hitched/features/budget/domain/budget_repository.dart';

class FakeBudgetRepository implements BudgetRepository {
  WeddingBudget? budget = const WeddingBudget(
    id: 1,
    weddingId: 1,
    totalAmount: 30000,
    currency: 'USD',
    allocatedTotal: 12000,
    estimatedTotal: 10000,
    actualTotal: 9000,
    paidTotal: 3000,
    remainingAmount: 21000,
    outstandingAmount: 6000,
  );
  final categories = <BudgetCategory>[
    const BudgetCategory(
      id: 1,
      name: 'Venue',
      allocatedAmount: 12000,
      actualTotal: 9000,
      remainingAmount: 3000,
    ),
  ];
  final expenses = <BudgetExpense>[
    const BudgetExpense(
      id: 1,
      categoryId: 1,
      categoryName: 'Venue',
      name: 'Venue deposit',
      vendorName: 'Garden Hall',
      estimatedAmount: 10000,
      actualAmount: 9000,
      amountPaid: 3000,
      outstandingAmount: 6000,
      paymentStatus: ExpensePaymentStatus.partiallyPaid,
      isOverdue: false,
      notes: '',
    ),
  ];

  @override
  Future<WeddingBudget?> fetchBudget(int weddingId) async => budget;
  @override
  Future<List<BudgetCategory>> fetchCategories(int weddingId) async =>
      List.unmodifiable(categories);
  @override
  Future<List<BudgetExpense>> fetchExpenses(int weddingId) async =>
      List.unmodifiable(expenses);
  @override
  Future<List<BudgetVendor>> fetchVendors(int weddingId) async => const [
    BudgetVendor(id: 1, name: 'Garden Hall', serviceCategory: 'Venue'),
  ];

  @override
  Future<WeddingBudget> createBudget(int weddingId, BudgetDraft draft) async {
    budget = WeddingBudget(
      id: 1,
      weddingId: weddingId,
      totalAmount: draft.totalAmount,
      currency: draft.currency,
      allocatedTotal: 0,
      estimatedTotal: 0,
      actualTotal: 0,
      paidTotal: 0,
      remainingAmount: draft.totalAmount,
      outstandingAmount: 0,
    );
    return budget!;
  }

  @override
  Future<WeddingBudget> updateBudget(int weddingId, BudgetDraft draft) async =>
      createBudget(weddingId, draft);

  @override
  Future<BudgetCategory> createCategory(
    int weddingId,
    BudgetCategoryDraft draft,
  ) async {
    final category = BudgetCategory(
      id: categories.length + 1,
      name: draft.name,
      allocatedAmount: draft.allocatedAmount,
      actualTotal: 0,
      remainingAmount: draft.allocatedAmount,
    );
    categories.add(category);
    return category;
  }

  @override
  Future<BudgetCategory> updateCategory(
    int weddingId,
    int categoryId,
    BudgetCategoryDraft draft,
  ) async => createCategory(weddingId, draft);

  @override
  Future<void> deleteCategory(int weddingId, int categoryId) async {
    categories.removeWhere((category) => category.id == categoryId);
    expenses.removeWhere((expense) => expense.categoryId == categoryId);
  }

  @override
  Future<BudgetExpense> createExpense(
    int weddingId,
    BudgetExpenseDraft draft,
  ) async => throw UnimplementedError();

  @override
  Future<BudgetExpense> updateExpense(
    int weddingId,
    int expenseId,
    BudgetExpenseDraft draft,
  ) async => throw UnimplementedError();

  @override
  Future<BudgetExpense> updateAmountPaid(
    int weddingId,
    int expenseId,
    double amountPaid,
  ) async {
    final old = expenses.firstWhere((expense) => expense.id == expenseId);
    final status = amountPaid <= 0
        ? ExpensePaymentStatus.unpaid
        : amountPaid >= old.actualAmount
        ? ExpensePaymentStatus.paid
        : ExpensePaymentStatus.partiallyPaid;
    final updated = BudgetExpense(
      id: old.id,
      categoryId: old.categoryId,
      categoryName: old.categoryName,
      name: old.name,
      vendor: old.vendor,
      vendorName: old.vendorName,
      estimatedAmount: old.estimatedAmount,
      actualAmount: old.actualAmount,
      amountPaid: amountPaid,
      outstandingAmount: old.actualAmount - amountPaid,
      paymentStatus: status,
      dueDate: old.dueDate,
      isOverdue: old.isOverdue,
      notes: old.notes,
    );
    expenses[expenses.indexOf(old)] = updated;
    return updated;
  }

  @override
  Future<void> deleteExpense(int weddingId, int expenseId) async {
    expenses.removeWhere((expense) => expense.id == expenseId);
  }
}
