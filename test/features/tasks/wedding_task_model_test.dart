import 'package:flutter_test/flutter_test.dart';
import 'package:hitched/features/tasks/domain/wedding_task.dart';

void main() {
  test('parses a DRF task with its wedding membership assignee', () {
    final task = WeddingTask.fromJson({
      'id': 9,
      'wedding': 3,
      'title': 'Confirm menu',
      'description': 'Call the caterer.',
      'status': 'in_progress',
      'priority': 'high',
      'due_date': '2027-02-10',
      'assignee': {
        'id': 12,
        'user': {
          'id': 4,
          'email': 'jamie@example.com',
          'first_name': 'Jamie',
          'last_name': 'Taylor',
        },
        'role': 'partner',
        'joined_at': '2026-08-01T10:00:00Z',
      },
      'created_by': {
        'id': 2,
        'email': 'alex@example.com',
        'first_name': 'Alex',
        'last_name': 'Morgan',
      },
      'completed_at': null,
      'created_at': '2026-08-01T10:00:00Z',
      'updated_at': '2026-08-01T10:00:00Z',
    });

    expect(task.status, WeddingTaskStatus.inProgress);
    expect(task.priority, WeddingTaskPriority.high);
    expect(task.assignee?.id, 12);
    expect(task.assignee?.user.displayName, 'Jamie Taylor');
    expect(task.createdBy?.email, 'alex@example.com');
  });
}
