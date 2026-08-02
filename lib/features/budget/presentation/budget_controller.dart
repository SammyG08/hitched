import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth/presentation/auth_controller.dart';
import '../../dashboard/presentation/dashboard_controller.dart';
import '../../weddings/presentation/wedding_workspace_controller.dart';
import '../data/django_budget_repository.dart';
import '../domain/budget_models.dart';
import '../domain/budget_repository.dart';

final budgetRepositoryProvider = Provider<BudgetRepository>((ref) {
  return DjangoBudgetRepository(ref.watch(apiClientProvider));
});

final budgetProvider = AsyncNotifierProvider<BudgetController, BudgetState>(
  BudgetController.new,
);

class BudgetState {
  const BudgetState({
    required this.categories,
    required this.expenses,
    required this.vendors,
    this.budget,
    this.query = '',
    this.categoryFilter,
    this.paymentFilter,
    this.isMutating = false,
    this.actionError,
  });

  const BudgetState.empty()
    : budget = null,
      categories = const [],
      expenses = const [],
      vendors = const [],
      query = '',
      categoryFilter = null,
      paymentFilter = null,
      isMutating = false,
      actionError = null;

  final WeddingBudget? budget;
  final List<BudgetCategory> categories;
  final List<BudgetExpense> expenses;
  final List<BudgetVendor> vendors;
  final String query;
  final int? categoryFilter;
  final ExpensePaymentStatus? paymentFilter;
  final bool isMutating;
  final Object? actionError;

  List<BudgetExpense> get visibleExpenses {
    final search = query.trim().toLowerCase();
    return expenses
        .where((expense) {
          if (categoryFilter != null && expense.categoryId != categoryFilter) {
            return false;
          }
          if (paymentFilter != null && expense.paymentStatus != paymentFilter) {
            return false;
          }
          if (search.isEmpty) return true;
          return [
            expense.name,
            expense.categoryName,
            expense.displayVendorName,
            expense.notes,
          ].join(' ').toLowerCase().contains(search);
        })
        .toList(growable: false);
  }

  BudgetState copyWith({
    WeddingBudget? budget,
    List<BudgetCategory>? categories,
    List<BudgetExpense>? expenses,
    List<BudgetVendor>? vendors,
    String? query,
    int? categoryFilter,
    ExpensePaymentStatus? paymentFilter,
    bool? isMutating,
    Object? actionError,
    bool clearCategoryFilter = false,
    bool clearPaymentFilter = false,
    bool clearActionError = false,
  }) {
    return BudgetState(
      budget: budget ?? this.budget,
      categories: categories ?? this.categories,
      expenses: expenses ?? this.expenses,
      vendors: vendors ?? this.vendors,
      query: query ?? this.query,
      categoryFilter: clearCategoryFilter
          ? null
          : categoryFilter ?? this.categoryFilter,
      paymentFilter: clearPaymentFilter
          ? null
          : paymentFilter ?? this.paymentFilter,
      isMutating: isMutating ?? this.isMutating,
      actionError: clearActionError ? null : actionError ?? this.actionError,
    );
  }
}

class BudgetController extends AsyncNotifier<BudgetState> {
  BudgetRepository get _repository => ref.read(budgetRepositoryProvider);

  int? get _weddingId =>
      ref.read(weddingWorkspaceProvider).value?.selectedWedding?.id;

  @override
  Future<BudgetState> build() async {
    final workspace = ref.watch(weddingWorkspaceProvider);
    if (!workspace.hasValue) return const BudgetState.empty();
    final weddingId = workspace.requireValue.selectedWedding?.id;
    if (weddingId == null) return const BudgetState.empty();
    return _fetch(weddingId);
  }

  Future<BudgetState> _fetch(int weddingId, [BudgetState? previous]) async {
    final budget = await _repository.fetchBudget(weddingId);
    final vendorsFuture = _repository.fetchVendors(weddingId);
    if (budget == null) {
      return BudgetState(
        categories: const [],
        expenses: const [],
        vendors: await vendorsFuture,
        query: previous?.query ?? '',
      );
    }
    final results = await Future.wait([
      _repository.fetchCategories(weddingId),
      _repository.fetchExpenses(weddingId),
      vendorsFuture,
    ]);
    return BudgetState(
      budget: budget,
      categories: results[0] as List<BudgetCategory>,
      expenses: results[1] as List<BudgetExpense>,
      vendors: results[2] as List<BudgetVendor>,
      query: previous?.query ?? '',
      categoryFilter: previous?.categoryFilter,
      paymentFilter: previous?.paymentFilter,
    );
  }

  Future<void> refresh() async {
    final weddingId = _weddingId;
    if (weddingId == null) return;
    final previous = state.value;
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => _fetch(weddingId, previous));
  }

  void setQuery(String query) {
    state = AsyncData(state.requireValue.copyWith(query: query));
  }

  void setCategoryFilter(int? categoryId) {
    state = AsyncData(
      state.requireValue.copyWith(
        categoryFilter: categoryId,
        clearCategoryFilter: categoryId == null,
      ),
    );
  }

  void setPaymentFilter(ExpensePaymentStatus? status) {
    state = AsyncData(
      state.requireValue.copyWith(
        paymentFilter: status,
        clearPaymentFilter: status == null,
      ),
    );
  }

  BudgetCategory? categoryById(int id) {
    return state.value?.categories.where((item) => item.id == id).firstOrNull;
  }

  BudgetExpense? expenseById(int id) {
    return state.value?.expenses.where((item) => item.id == id).firstOrNull;
  }

  Future<bool> saveBudget(BudgetDraft draft) {
    return _mutate((weddingId) async {
      if (state.requireValue.budget == null) {
        await _repository.createBudget(weddingId, draft);
      } else {
        await _repository.updateBudget(weddingId, draft);
      }
    });
  }

  Future<bool> saveCategory({
    int? categoryId,
    required BudgetCategoryDraft draft,
  }) {
    return _mutate((weddingId) async {
      if (categoryId == null) {
        await _repository.createCategory(weddingId, draft);
      } else {
        await _repository.updateCategory(weddingId, categoryId, draft);
      }
    });
  }

  Future<bool> deleteCategory(int categoryId) {
    return _mutate(
      (weddingId) => _repository.deleteCategory(weddingId, categoryId),
    );
  }

  Future<bool> saveExpense({
    int? expenseId,
    required BudgetExpenseDraft draft,
  }) {
    return _mutate((weddingId) async {
      if (expenseId == null) {
        await _repository.createExpense(weddingId, draft);
      } else {
        await _repository.updateExpense(weddingId, expenseId, draft);
      }
    });
  }

  Future<bool> recordPayment(int expenseId, double amountPaid) {
    return _mutate(
      (weddingId) =>
          _repository.updateAmountPaid(weddingId, expenseId, amountPaid),
    );
  }

  Future<bool> deleteExpense(int expenseId) {
    return _mutate(
      (weddingId) => _repository.deleteExpense(weddingId, expenseId),
    );
  }

  Future<bool> _mutate(Future<void> Function(int weddingId) operation) async {
    final weddingId = _weddingId;
    if (weddingId == null) return false;
    final current = state.requireValue;
    state = AsyncData(
      current.copyWith(isMutating: true, clearActionError: true),
    );
    try {
      await operation(weddingId);
      state = AsyncData(await _fetch(weddingId, current));
      ref.invalidate(dashboardProvider);
      return true;
    } catch (error) {
      state = AsyncData(
        current.copyWith(isMutating: false, actionError: error),
      );
      return false;
    }
  }
}
