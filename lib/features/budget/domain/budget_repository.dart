import 'budget_models.dart';

abstract interface class BudgetRepository {
  Future<WeddingBudget?> fetchBudget(int weddingId);
  Future<List<BudgetCategory>> fetchCategories(int weddingId);
  Future<List<BudgetExpense>> fetchExpenses(int weddingId);
  Future<List<BudgetVendor>> fetchVendors(int weddingId);

  Future<WeddingBudget> createBudget(int weddingId, BudgetDraft draft);
  Future<WeddingBudget> updateBudget(int weddingId, BudgetDraft draft);
  Future<BudgetCategory> createCategory(
    int weddingId,
    BudgetCategoryDraft draft,
  );
  Future<BudgetCategory> updateCategory(
    int weddingId,
    int categoryId,
    BudgetCategoryDraft draft,
  );
  Future<void> deleteCategory(int weddingId, int categoryId);
  Future<BudgetExpense> createExpense(int weddingId, BudgetExpenseDraft draft);
  Future<BudgetExpense> updateExpense(
    int weddingId,
    int expenseId,
    BudgetExpenseDraft draft,
  );
  Future<BudgetExpense> updateAmountPaid(
    int weddingId,
    int expenseId,
    double amountPaid,
  );
  Future<void> deleteExpense(int weddingId, int expenseId);
}
