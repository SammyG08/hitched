enum ExpensePaymentStatus {
  unpaid('unpaid', 'Unpaid'),
  partiallyPaid('partially_paid', 'Partially paid'),
  paid('paid', 'Paid');

  const ExpensePaymentStatus(this.apiValue, this.label);

  final String apiValue;
  final String label;

  static ExpensePaymentStatus fromApi(String value) {
    return values.firstWhere((status) => status.apiValue == value);
  }
}

class WeddingBudget {
  const WeddingBudget({
    required this.id,
    required this.weddingId,
    required this.totalAmount,
    required this.currency,
    required this.allocatedTotal,
    required this.estimatedTotal,
    required this.actualTotal,
    required this.paidTotal,
    required this.remainingAmount,
    required this.outstandingAmount,
  });

  final int id;
  final int weddingId;
  final double totalAmount;
  final String currency;
  final double allocatedTotal;
  final double estimatedTotal;
  final double actualTotal;
  final double paidTotal;
  final double remainingAmount;
  final double outstandingAmount;

  double get spentProgress =>
      totalAmount <= 0 ? 0 : (actualTotal / totalAmount).clamp(0, 1).toDouble();

  factory WeddingBudget.fromJson(Map<String, dynamic> json) {
    return WeddingBudget(
      id: json['id'] as int,
      weddingId: json['wedding'] as int,
      totalAmount: _money(json['total_amount']),
      currency: json['currency'] as String,
      allocatedTotal: _money(json['allocated_total']),
      estimatedTotal: _money(json['estimated_total']),
      actualTotal: _money(json['actual_total']),
      paidTotal: _money(json['paid_total']),
      remainingAmount: _money(json['remaining_amount']),
      outstandingAmount: _money(json['outstanding_amount']),
    );
  }
}

class BudgetCategory {
  const BudgetCategory({
    required this.id,
    required this.name,
    required this.allocatedAmount,
    required this.actualTotal,
    required this.remainingAmount,
  });

  final int id;
  final String name;
  final double allocatedAmount;
  final double actualTotal;
  final double remainingAmount;

  double get spentProgress => allocatedAmount <= 0
      ? 0
      : (actualTotal / allocatedAmount).clamp(0, 1).toDouble();

  factory BudgetCategory.fromJson(Map<String, dynamic> json) {
    return BudgetCategory(
      id: json['id'] as int,
      name: json['name'] as String,
      allocatedAmount: _money(json['allocated_amount']),
      actualTotal: _money(json['actual_total']),
      remainingAmount: _money(json['remaining_amount']),
    );
  }
}

class BudgetVendor {
  const BudgetVendor({
    required this.id,
    required this.name,
    required this.serviceCategory,
  });

  final int id;
  final String name;
  final String serviceCategory;

  factory BudgetVendor.fromJson(Map<String, dynamic> json) {
    return BudgetVendor(
      id: json['id'] as int,
      name: json['name'] as String,
      serviceCategory: json['service_category'] as String? ?? '',
    );
  }
}

class BudgetExpense {
  const BudgetExpense({
    required this.id,
    required this.categoryId,
    required this.categoryName,
    required this.name,
    required this.vendorName,
    required this.estimatedAmount,
    required this.actualAmount,
    required this.amountPaid,
    required this.outstandingAmount,
    required this.paymentStatus,
    required this.isOverdue,
    required this.notes,
    this.vendor,
    this.dueDate,
  });

  final int id;
  final int categoryId;
  final String categoryName;
  final String name;
  final BudgetVendor? vendor;
  final String vendorName;
  final double estimatedAmount;
  final double actualAmount;
  final double amountPaid;
  final double outstandingAmount;
  final ExpensePaymentStatus paymentStatus;
  final DateTime? dueDate;
  final bool isOverdue;
  final String notes;

  String get displayVendorName => vendor?.name ?? vendorName;

  factory BudgetExpense.fromJson(Map<String, dynamic> json) {
    final category = Map<String, dynamic>.from(json['category'] as Map);
    final vendor = json['vendor'];
    return BudgetExpense(
      id: json['id'] as int,
      categoryId: category['id'] as int,
      categoryName: category['name'] as String,
      name: json['name'] as String,
      vendor: vendor is Map
          ? BudgetVendor.fromJson(Map<String, dynamic>.from(vendor))
          : null,
      vendorName: json['vendor_name'] as String? ?? '',
      estimatedAmount: _money(json['estimated_amount']),
      actualAmount: _money(json['actual_amount']),
      amountPaid: _money(json['amount_paid']),
      outstandingAmount: _money(json['outstanding_amount']),
      paymentStatus: ExpensePaymentStatus.fromApi(
        json['payment_status'] as String,
      ),
      dueDate: _date(json['due_date']),
      isOverdue: json['is_overdue'] as bool,
      notes: json['notes'] as String? ?? '',
    );
  }
}

class BudgetDraft {
  const BudgetDraft({required this.totalAmount, required this.currency});

  final double totalAmount;
  final String currency;

  Map<String, dynamic> toJson() => {
    'total_amount': totalAmount.toStringAsFixed(2),
    'currency': currency.trim().toUpperCase(),
  };
}

class BudgetCategoryDraft {
  const BudgetCategoryDraft({
    required this.name,
    required this.allocatedAmount,
  });

  final String name;
  final double allocatedAmount;

  Map<String, dynamic> toJson() => {
    'name': name.trim(),
    'allocated_amount': allocatedAmount.toStringAsFixed(2),
  };
}

class BudgetExpenseDraft {
  const BudgetExpenseDraft({
    required this.categoryId,
    required this.name,
    required this.vendorName,
    required this.estimatedAmount,
    required this.actualAmount,
    required this.amountPaid,
    required this.notes,
    this.vendorId,
    this.dueDate,
  });

  final int categoryId;
  final String name;
  final int? vendorId;
  final String vendorName;
  final double estimatedAmount;
  final double actualAmount;
  final double amountPaid;
  final DateTime? dueDate;
  final String notes;

  Map<String, dynamic> toJson() => {
    'category_id': categoryId,
    'name': name.trim(),
    'vendor_id': vendorId,
    'vendor_name': vendorName.trim(),
    'estimated_amount': estimatedAmount.toStringAsFixed(2),
    'actual_amount': actualAmount.toStringAsFixed(2),
    'amount_paid': amountPaid.toStringAsFixed(2),
    'due_date': dueDate == null ? null : _apiDate(dueDate!),
    'notes': notes.trim(),
  };
}

double _money(dynamic value) => double.parse(value.toString());

DateTime? _date(dynamic value) {
  return value == null ? null : DateTime.tryParse(value.toString());
}

String _apiDate(DateTime date) {
  final month = date.month.toString().padLeft(2, '0');
  final day = date.day.toString().padLeft(2, '0');
  return '${date.year}-$month-$day';
}
