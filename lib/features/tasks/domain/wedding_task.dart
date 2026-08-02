import '../../weddings/domain/wedding.dart';

enum WeddingTaskStatus {
  todo('todo', 'To do'),
  inProgress('in_progress', 'In progress'),
  done('done', 'Done');

  const WeddingTaskStatus(this.apiValue, this.label);

  final String apiValue;
  final String label;

  static WeddingTaskStatus fromApi(String value) {
    return values.firstWhere((status) => status.apiValue == value);
  }
}

enum WeddingTaskPriority {
  low('low', 'Low'),
  medium('medium', 'Medium'),
  high('high', 'High');

  const WeddingTaskPriority(this.apiValue, this.label);

  final String apiValue;
  final String label;

  static WeddingTaskPriority fromApi(String value) {
    return values.firstWhere((priority) => priority.apiValue == value);
  }
}

class WeddingTask {
  const WeddingTask({
    required this.id,
    required this.weddingId,
    required this.title,
    required this.description,
    required this.status,
    required this.priority,
    required this.createdAt,
    required this.updatedAt,
    this.dueDate,
    this.assignee,
    this.createdBy,
    this.completedAt,
  });

  final int id;
  final int weddingId;
  final String title;
  final String description;
  final WeddingTaskStatus status;
  final WeddingTaskPriority priority;
  final DateTime? dueDate;
  final WeddingMember? assignee;
  final WeddingMemberUser? createdBy;
  final DateTime? completedAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  bool get isDone => status == WeddingTaskStatus.done;

  factory WeddingTask.fromJson(Map<String, dynamic> json) {
    final assignee = json['assignee'];
    final createdBy = json['created_by'];
    return WeddingTask(
      id: json['id'] as int,
      weddingId: json['wedding'] as int,
      title: json['title'] as String,
      description: json['description'] as String? ?? '',
      status: WeddingTaskStatus.fromApi(json['status'] as String),
      priority: WeddingTaskPriority.fromApi(json['priority'] as String),
      dueDate: _date(json['due_date']),
      assignee: assignee is Map
          ? WeddingMember.fromJson(Map<String, dynamic>.from(assignee))
          : null,
      createdBy: createdBy is Map
          ? WeddingMemberUser.fromJson(Map<String, dynamic>.from(createdBy))
          : null,
      completedAt: _date(json['completed_at']),
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }
}

class TaskDraft {
  const TaskDraft({
    required this.title,
    required this.description,
    required this.status,
    required this.priority,
    this.dueDate,
    this.assigneeId,
  });

  final String title;
  final String description;
  final WeddingTaskStatus status;
  final WeddingTaskPriority priority;
  final DateTime? dueDate;
  final int? assigneeId;

  Map<String, dynamic> toJson() {
    return {
      'title': title.trim(),
      'description': description.trim(),
      'status': status.apiValue,
      'priority': priority.apiValue,
      'due_date': dueDate == null ? null : _dateOnly(dueDate!),
      'assignee_id': assigneeId,
    };
  }
}

DateTime? _date(dynamic value) {
  return value == null ? null : DateTime.tryParse(value.toString());
}

String _dateOnly(DateTime date) {
  final year = date.year.toString().padLeft(4, '0');
  final month = date.month.toString().padLeft(2, '0');
  final day = date.day.toString().padLeft(2, '0');
  return '$year-$month-$day';
}
