import 'package:flutter_test/flutter_test.dart';
import 'package:hitched/features/budget/domain/budget_models.dart';

void main() {
  test('parses DRF decimal strings and computed payment fields', () {
    final budget = WeddingBudget.fromJson({
      'id': 3,
      'wedding': 7,
      'total_amount': '25000.00',
      'currency': 'GHS',
      'allocated_total': '18000.00',
      'estimated_total': '15000.00',
      'actual_total': '12000.50',
      'paid_total': '5000.00',
      'remaining_amount': '12999.50',
      'outstanding_amount': '7000.50',
    });
    final expense = BudgetExpense.fromJson({
      'id': 8,
      'category': {'id': 2, 'name': 'Catering'},
      'name': 'Dinner service',
      'vendor': {
        'id': 4,
        'name': 'Golden Spoon',
        'service_category': 'Catering',
      },
      'vendor_name': '',
      'estimated_amount': '5000.00',
      'actual_amount': '4500.00',
      'amount_paid': '1500.00',
      'outstanding_amount': '3000.00',
      'payment_status': 'partially_paid',
      'due_date': '2026-09-15',
      'is_overdue': false,
      'notes': 'Second installment due.',
    });

    expect(budget.actualTotal, 12000.50);
    expect(budget.currency, 'GHS');
    expect(expense.paymentStatus, ExpensePaymentStatus.partiallyPaid);
    expect(expense.displayVendorName, 'Golden Spoon');
    expect(expense.dueDate, DateTime(2026, 9, 15));
  });
}
