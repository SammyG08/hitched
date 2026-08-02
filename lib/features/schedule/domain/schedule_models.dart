import '../../weddings/domain/wedding.dart';

enum ScheduleEventType {
  preparation('preparation', 'Preparation'),
  ceremony('ceremony', 'Ceremony'),
  cocktail('cocktail', 'Cocktail'),
  reception('reception', 'Reception'),
  meal('meal', 'Meal'),
  speeches('speeches', 'Speeches'),
  entertainment('entertainment', 'Entertainment'),
  transportation('transportation', 'Transportation'),
  photos('photos', 'Photos'),
  other('other', 'Other');

  const ScheduleEventType(this.apiValue, this.label);
  final String apiValue;
  final String label;

  static ScheduleEventType fromApi(String value) {
    return values.firstWhere((type) => type.apiValue == value);
  }
}

enum ScheduleEventStatus {
  planned('planned', 'Planned'),
  confirmed('confirmed', 'Confirmed'),
  completed('completed', 'Completed'),
  cancelled('cancelled', 'Cancelled');

  const ScheduleEventStatus(this.apiValue, this.label);
  final String apiValue;
  final String label;

  static ScheduleEventStatus fromApi(String value) {
    return values.firstWhere((status) => status.apiValue == value);
  }
}

enum ScheduleTimeFilter { all, upcoming, past }

class ScheduleVendorReference {
  const ScheduleVendorReference({
    required this.id,
    required this.name,
    required this.serviceCategory,
  });

  final int id;
  final String name;
  final String serviceCategory;

  factory ScheduleVendorReference.fromJson(Map<String, dynamic> json) {
    return ScheduleVendorReference(
      id: json['id'] as int,
      name: json['name'] as String,
      serviceCategory: json['service_category'] as String? ?? '',
    );
  }
}

class ScheduleEvent {
  const ScheduleEvent({
    required this.id,
    required this.weddingId,
    required this.title,
    required this.eventType,
    required this.startAt,
    required this.endAt,
    required this.durationMinutes,
    required this.location,
    required this.status,
    required this.isPast,
    required this.createdBy,
    required this.notes,
    this.responsibleMember,
    this.vendor,
  });

  final int id;
  final int weddingId;
  final String title;
  final ScheduleEventType eventType;
  final DateTime startAt;
  final DateTime endAt;
  final int durationMinutes;
  final String location;
  final ScheduleEventStatus status;
  final WeddingMember? responsibleMember;
  final ScheduleVendorReference? vendor;
  final WeddingMemberUser createdBy;
  final bool isPast;
  final String notes;

  factory ScheduleEvent.fromJson(Map<String, dynamic> json) {
    final member = json['responsible_member'];
    final vendor = json['vendor'];
    return ScheduleEvent(
      id: json['id'] as int,
      weddingId: json['wedding'] as int,
      title: json['title'] as String,
      eventType: ScheduleEventType.fromApi(json['event_type'] as String),
      startAt: DateTime.parse(json['start_at'] as String).toLocal(),
      endAt: DateTime.parse(json['end_at'] as String).toLocal(),
      durationMinutes: json['duration_minutes'] as int,
      location: json['location'] as String? ?? '',
      status: ScheduleEventStatus.fromApi(json['status'] as String),
      responsibleMember: member is Map
          ? WeddingMember.fromJson(Map<String, dynamic>.from(member))
          : null,
      vendor: vendor is Map
          ? ScheduleVendorReference.fromJson(Map<String, dynamic>.from(vendor))
          : null,
      createdBy: WeddingMemberUser.fromJson(
        Map<String, dynamic>.from(json['created_by'] as Map),
      ),
      isPast: json['is_past'] as bool,
      notes: json['notes'] as String? ?? '',
    );
  }
}

class ScheduleEventDraft {
  const ScheduleEventDraft({
    required this.title,
    required this.eventType,
    required this.startAt,
    required this.endAt,
    required this.location,
    required this.status,
    required this.notes,
    this.responsibleMemberId,
    this.vendorId,
  });

  final String title;
  final ScheduleEventType eventType;
  final DateTime startAt;
  final DateTime endAt;
  final String location;
  final ScheduleEventStatus status;
  final int? responsibleMemberId;
  final int? vendorId;
  final String notes;

  Map<String, dynamic> toJson() => {
    'title': title.trim(),
    'event_type': eventType.apiValue,
    'start_at': startAt.toUtc().toIso8601String(),
    'end_at': endAt.toUtc().toIso8601String(),
    'location': location.trim(),
    'status': status.apiValue,
    'responsible_member_id': responsibleMemberId,
    'vendor_id': vendorId,
    'notes': notes.trim(),
  };
}
