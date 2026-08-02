import 'package:flutter_test/flutter_test.dart';
import 'package:hitched/features/dashboard/domain/dashboard.dart';

void main() {
  test('parses the complete Django dashboard contract', () {
    final dashboard = Dashboard.fromJson({
      'wedding': {
        'id': 8,
        'name': 'Alex & Jamie',
        'wedding_date': '2027-06-12',
        'location': 'Accra',
        'days_until_wedding': 120,
        'has_passed': false,
      },
      'tasks': {
        'total': 9,
        'todo': 7,
        'in_progress': 1,
        'done': 1,
        'overdue': 1,
        'completion_percentage': 11.1,
      },
      'guests': {
        'households': 2,
        'invitations_sent': 1,
        'total': 3,
        'attending': 1,
        'declined': 1,
        'pending': 1,
        'dietary_requirements': 1,
      },
      'budget': {
        'configured': true,
        'currency': 'GHS',
        'total_amount': '10000.00',
        'allocated_total': '6000.00',
        'estimated_total': '4200.00',
        'actual_total': '3500.00',
        'paid_total': '1000.00',
        'remaining_amount': '6500.00',
        'outstanding_amount': '2500.00',
        'overdue_expenses': 1,
      },
      'vendors': {
        'total': 2,
        'researching': 1,
        'contacted': 0,
        'shortlisted': 0,
        'booked': 1,
        'rejected': 0,
        'quotes_received': 1,
        'contracts_signed': 1,
      },
      'upcoming_tasks': [
        {
          'id': 4,
          'title': 'Next task',
          'status': 'in_progress',
          'priority': 'high',
          'due_date': '2027-02-01',
          'assignee_name': 'Jamie Taylor',
        },
      ],
      'upcoming_payments': [
        {
          'id': 3,
          'name': 'Upcoming payment',
          'vendor_name': 'Example Studios',
          'due_date': '2027-02-02',
          'payment_status': 'unpaid',
          'actual_amount': '1000.00',
          'amount_paid': '0.00',
          'outstanding_amount': '1000.00',
        },
      ],
      'schedule': {
        'upcoming_count': 1,
        'next_events': [
          {
            'id': 2,
            'title': 'Venue walkthrough',
            'event_type': 'appointment',
            'start_at': '2027-02-03T10:00:00Z',
            'end_at': '2027-02-03T11:00:00Z',
            'location': 'The venue',
            'status': 'confirmed',
            'responsible_member_name': 'Jamie Taylor',
            'vendor_name': null,
          },
        ],
      },
    });

    expect(dashboard.wedding.id, 8);
    expect(dashboard.tasks.completionPercentage, 11.1);
    expect(dashboard.budget.actualTotal, 3500);
    expect(dashboard.upcomingTasks.single.assigneeName, 'Jamie Taylor');
    expect(dashboard.upcomingPayments.single.outstandingAmount, 1000);
    expect(dashboard.schedule.nextEvents.single.title, 'Venue walkthrough');
  });
}
