class Dashboard {
  const Dashboard({
    required this.wedding,
    required this.tasks,
    required this.guests,
    required this.budget,
    required this.vendors,
    required this.upcomingTasks,
    required this.upcomingPayments,
    required this.schedule,
  });

  final DashboardWedding wedding;
  final TaskProgress tasks;
  final GuestProgress guests;
  final BudgetHealth budget;
  final VendorProgress vendors;
  final List<UpcomingTask> upcomingTasks;
  final List<UpcomingPayment> upcomingPayments;
  final ScheduleSummary schedule;

  factory Dashboard.fromJson(Map<String, dynamic> json) {
    return Dashboard(
      wedding: DashboardWedding.fromJson(_map(json['wedding'])),
      tasks: TaskProgress.fromJson(_map(json['tasks'])),
      guests: GuestProgress.fromJson(_map(json['guests'])),
      budget: BudgetHealth.fromJson(_map(json['budget'])),
      vendors: VendorProgress.fromJson(_map(json['vendors'])),
      upcomingTasks: _list(json['upcoming_tasks'])
          .map((item) => UpcomingTask.fromJson(_map(item)))
          .toList(growable: false),
      upcomingPayments: _list(json['upcoming_payments'])
          .map((item) => UpcomingPayment.fromJson(_map(item)))
          .toList(growable: false),
      schedule: ScheduleSummary.fromJson(_map(json['schedule'])),
    );
  }
}

class DashboardWedding {
  const DashboardWedding({
    required this.id,
    required this.name,
    required this.location,
    required this.hasPassed,
    this.weddingDate,
    this.daysUntilWedding,
  });

  final int id;
  final String name;
  final DateTime? weddingDate;
  final String location;
  final int? daysUntilWedding;
  final bool hasPassed;

  factory DashboardWedding.fromJson(Map<String, dynamic> json) {
    return DashboardWedding(
      id: json['id'] as int,
      name: json['name'] as String,
      weddingDate: _date(json['wedding_date']),
      location: json['location'] as String? ?? '',
      daysUntilWedding: json['days_until_wedding'] as int?,
      hasPassed: json['has_passed'] as bool,
    );
  }
}

class TaskProgress {
  const TaskProgress({
    required this.total,
    required this.todo,
    required this.inProgress,
    required this.done,
    required this.overdue,
    required this.completionPercentage,
  });

  final int total;
  final int todo;
  final int inProgress;
  final int done;
  final int overdue;
  final double completionPercentage;

  factory TaskProgress.fromJson(Map<String, dynamic> json) {
    return TaskProgress(
      total: json['total'] as int,
      todo: json['todo'] as int,
      inProgress: json['in_progress'] as int,
      done: json['done'] as int,
      overdue: json['overdue'] as int,
      completionPercentage: _number(json['completion_percentage']),
    );
  }
}

class GuestProgress {
  const GuestProgress({
    required this.households,
    required this.invitationsSent,
    required this.total,
    required this.attending,
    required this.declined,
    required this.pending,
    required this.dietaryRequirements,
  });

  final int households;
  final int invitationsSent;
  final int total;
  final int attending;
  final int declined;
  final int pending;
  final int dietaryRequirements;

  factory GuestProgress.fromJson(Map<String, dynamic> json) {
    return GuestProgress(
      households: json['households'] as int,
      invitationsSent: json['invitations_sent'] as int,
      total: json['total'] as int,
      attending: json['attending'] as int,
      declined: json['declined'] as int,
      pending: json['pending'] as int,
      dietaryRequirements: json['dietary_requirements'] as int,
    );
  }
}

class BudgetHealth {
  const BudgetHealth({
    required this.configured,
    required this.totalAmount,
    required this.allocatedTotal,
    required this.estimatedTotal,
    required this.actualTotal,
    required this.paidTotal,
    required this.remainingAmount,
    required this.outstandingAmount,
    required this.overdueExpenses,
    this.currency,
  });

  final bool configured;
  final String? currency;
  final double totalAmount;
  final double allocatedTotal;
  final double estimatedTotal;
  final double actualTotal;
  final double paidTotal;
  final double remainingAmount;
  final double outstandingAmount;
  final int overdueExpenses;

  factory BudgetHealth.fromJson(Map<String, dynamic> json) {
    return BudgetHealth(
      configured: json['configured'] as bool,
      currency: json['currency'] as String?,
      totalAmount: _number(json['total_amount']),
      allocatedTotal: _number(json['allocated_total']),
      estimatedTotal: _number(json['estimated_total']),
      actualTotal: _number(json['actual_total']),
      paidTotal: _number(json['paid_total']),
      remainingAmount: _number(json['remaining_amount']),
      outstandingAmount: _number(json['outstanding_amount']),
      overdueExpenses: json['overdue_expenses'] as int,
    );
  }
}

class VendorProgress {
  const VendorProgress({
    required this.total,
    required this.researching,
    required this.contacted,
    required this.shortlisted,
    required this.booked,
    required this.rejected,
    required this.quotesReceived,
    required this.contractsSigned,
  });

  final int total;
  final int researching;
  final int contacted;
  final int shortlisted;
  final int booked;
  final int rejected;
  final int quotesReceived;
  final int contractsSigned;

  factory VendorProgress.fromJson(Map<String, dynamic> json) {
    return VendorProgress(
      total: json['total'] as int,
      researching: json['researching'] as int,
      contacted: json['contacted'] as int,
      shortlisted: json['shortlisted'] as int,
      booked: json['booked'] as int,
      rejected: json['rejected'] as int,
      quotesReceived: json['quotes_received'] as int,
      contractsSigned: json['contracts_signed'] as int,
    );
  }
}

class UpcomingTask {
  const UpcomingTask({
    required this.id,
    required this.title,
    required this.status,
    required this.priority,
    this.dueDate,
    this.assigneeName,
  });

  final int id;
  final String title;
  final String status;
  final String priority;
  final DateTime? dueDate;
  final String? assigneeName;

  factory UpcomingTask.fromJson(Map<String, dynamic> json) {
    return UpcomingTask(
      id: json['id'] as int,
      title: json['title'] as String,
      status: json['status'] as String,
      priority: json['priority'] as String,
      dueDate: _date(json['due_date']),
      assigneeName: json['assignee_name'] as String?,
    );
  }
}

class UpcomingPayment {
  const UpcomingPayment({
    required this.id,
    required this.name,
    required this.paymentStatus,
    required this.actualAmount,
    required this.amountPaid,
    required this.outstandingAmount,
    this.vendorName,
    this.dueDate,
  });

  final int id;
  final String name;
  final String? vendorName;
  final DateTime? dueDate;
  final String paymentStatus;
  final double actualAmount;
  final double amountPaid;
  final double outstandingAmount;

  factory UpcomingPayment.fromJson(Map<String, dynamic> json) {
    return UpcomingPayment(
      id: json['id'] as int,
      name: json['name'] as String,
      vendorName: json['vendor_name'] as String?,
      dueDate: _date(json['due_date']),
      paymentStatus: json['payment_status'] as String,
      actualAmount: _number(json['actual_amount']),
      amountPaid: _number(json['amount_paid']),
      outstandingAmount: _number(json['outstanding_amount']),
    );
  }
}

class ScheduleSummary {
  const ScheduleSummary({
    required this.upcomingCount,
    required this.nextEvents,
  });

  final int upcomingCount;
  final List<UpcomingEvent> nextEvents;

  factory ScheduleSummary.fromJson(Map<String, dynamic> json) {
    return ScheduleSummary(
      upcomingCount: json['upcoming_count'] as int,
      nextEvents: _list(json['next_events'])
          .map((item) => UpcomingEvent.fromJson(_map(item)))
          .toList(growable: false),
    );
  }
}

class UpcomingEvent {
  const UpcomingEvent({
    required this.id,
    required this.title,
    required this.eventType,
    required this.startAt,
    required this.endAt,
    required this.location,
    required this.status,
    this.responsibleMemberName,
    this.vendorName,
  });

  final int id;
  final String title;
  final String eventType;
  final DateTime startAt;
  final DateTime endAt;
  final String location;
  final String status;
  final String? responsibleMemberName;
  final String? vendorName;

  factory UpcomingEvent.fromJson(Map<String, dynamic> json) {
    return UpcomingEvent(
      id: json['id'] as int,
      title: json['title'] as String,
      eventType: json['event_type'] as String,
      startAt: DateTime.parse(json['start_at'] as String),
      endAt: DateTime.parse(json['end_at'] as String),
      location: json['location'] as String? ?? '',
      status: json['status'] as String,
      responsibleMemberName: json['responsible_member_name'] as String?,
      vendorName: json['vendor_name'] as String?,
    );
  }
}

Map<String, dynamic> _map(dynamic value) {
  return Map<String, dynamic>.from(value as Map);
}

List<dynamic> _list(dynamic value) => value as List<dynamic>? ?? const [];

DateTime? _date(dynamic value) {
  return value == null ? null : DateTime.tryParse(value.toString());
}

double _number(dynamic value) {
  if (value is num) return value.toDouble();
  return double.parse(value.toString());
}
