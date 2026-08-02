enum InvitationStatus {
  notSent('not_sent', 'Not sent'),
  sent('sent', 'Sent');

  const InvitationStatus(this.apiValue, this.label);
  final String apiValue;
  final String label;

  static InvitationStatus fromApi(String value) {
    return values.firstWhere((status) => status.apiValue == value);
  }
}

enum GuestRsvpStatus {
  pending('pending', 'Pending'),
  attending('attending', 'Attending'),
  declined('declined', 'Declined');

  const GuestRsvpStatus(this.apiValue, this.label);
  final String apiValue;
  final String label;

  static GuestRsvpStatus fromApi(String value) {
    return values.firstWhere((status) => status.apiValue == value);
  }
}

class GuestHousehold {
  const GuestHousehold({
    required this.id,
    required this.weddingId,
    required this.name,
    required this.contactEmail,
    required this.contactPhone,
    required this.address,
    required this.invitationStatus,
    required this.guestCount,
    required this.attendingCount,
    required this.guests,
    this.invitationSentAt,
  });

  final int id;
  final int weddingId;
  final String name;
  final String contactEmail;
  final String contactPhone;
  final String address;
  final InvitationStatus invitationStatus;
  final DateTime? invitationSentAt;
  final int guestCount;
  final int attendingCount;
  final List<GuestSummary> guests;

  factory GuestHousehold.fromJson(Map<String, dynamic> json) {
    return GuestHousehold(
      id: json['id'] as int,
      weddingId: json['wedding'] as int,
      name: json['name'] as String,
      contactEmail: json['contact_email'] as String? ?? '',
      contactPhone: json['contact_phone'] as String? ?? '',
      address: json['address'] as String? ?? '',
      invitationStatus: InvitationStatus.fromApi(
        json['invitation_status'] as String,
      ),
      invitationSentAt: _date(json['invitation_sent_at']),
      guestCount: json['guest_count'] as int,
      attendingCount: json['attending_count'] as int,
      guests: (json['guests'] as List<dynamic>? ?? const [])
          .map(
            (item) =>
                GuestSummary.fromJson(Map<String, dynamic>.from(item as Map)),
          )
          .toList(growable: false),
    );
  }
}

class GuestSummary {
  const GuestSummary({
    required this.id,
    required this.fullName,
    required this.isPlusOne,
    required this.rsvpStatus,
  });

  final int id;
  final String fullName;
  final bool isPlusOne;
  final GuestRsvpStatus rsvpStatus;

  factory GuestSummary.fromJson(Map<String, dynamic> json) {
    return GuestSummary(
      id: json['id'] as int,
      fullName: json['full_name'] as String,
      isPlusOne: json['is_plus_one'] as bool,
      rsvpStatus: GuestRsvpStatus.fromApi(json['rsvp_status'] as String),
    );
  }
}

class WeddingGuest {
  const WeddingGuest({
    required this.id,
    required this.householdId,
    required this.householdName,
    required this.firstName,
    required this.lastName,
    required this.fullName,
    required this.email,
    required this.phone,
    required this.isPlusOne,
    required this.rsvpStatus,
    required this.dietaryRequirements,
    required this.tableName,
    required this.notes,
    this.plusOneOf,
  });

  final int id;
  final int householdId;
  final String householdName;
  final String firstName;
  final String lastName;
  final String fullName;
  final String email;
  final String phone;
  final bool isPlusOne;
  final GuestSummary? plusOneOf;
  final GuestRsvpStatus rsvpStatus;
  final String dietaryRequirements;
  final String tableName;
  final String notes;

  factory WeddingGuest.fromJson(Map<String, dynamic> json) {
    final household = Map<String, dynamic>.from(json['household'] as Map);
    final plusOneOf = json['plus_one_of'];
    return WeddingGuest(
      id: json['id'] as int,
      householdId: household['id'] as int,
      householdName: household['name'] as String,
      firstName: json['first_name'] as String? ?? '',
      lastName: json['last_name'] as String? ?? '',
      fullName: json['full_name'] as String,
      email: json['email'] as String? ?? '',
      phone: json['phone'] as String? ?? '',
      isPlusOne: json['is_plus_one'] as bool,
      plusOneOf: plusOneOf is Map
          ? GuestSummary.fromJson(Map<String, dynamic>.from(plusOneOf))
          : null,
      rsvpStatus: GuestRsvpStatus.fromApi(json['rsvp_status'] as String),
      dietaryRequirements: json['dietary_requirements'] as String? ?? '',
      tableName: json['table_name'] as String? ?? '',
      notes: json['notes'] as String? ?? '',
    );
  }
}

class HouseholdDraft {
  const HouseholdDraft({
    required this.name,
    required this.contactEmail,
    required this.contactPhone,
    required this.address,
    required this.invitationStatus,
  });

  final String name;
  final String contactEmail;
  final String contactPhone;
  final String address;
  final InvitationStatus invitationStatus;

  Map<String, dynamic> toJson() => {
    'name': name.trim(),
    'contact_email': contactEmail.trim(),
    'contact_phone': contactPhone.trim(),
    'address': address.trim(),
    'invitation_status': invitationStatus.apiValue,
  };
}

class GuestDraft {
  const GuestDraft({
    required this.householdId,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phone,
    required this.rsvpStatus,
    required this.dietaryRequirements,
    required this.tableName,
    required this.notes,
    this.plusOneOfId,
  });

  final int householdId;
  final String firstName;
  final String lastName;
  final String email;
  final String phone;
  final int? plusOneOfId;
  final GuestRsvpStatus rsvpStatus;
  final String dietaryRequirements;
  final String tableName;
  final String notes;

  Map<String, dynamic> toJson() => {
    'household_id': householdId,
    'first_name': firstName.trim(),
    'last_name': lastName.trim(),
    'email': email.trim(),
    'phone': phone.trim(),
    'plus_one_of_id': plusOneOfId,
    'rsvp_status': rsvpStatus.apiValue,
    'dietary_requirements': dietaryRequirements.trim(),
    'table_name': tableName.trim(),
    'notes': notes.trim(),
  };
}

DateTime? _date(dynamic value) {
  return value == null ? null : DateTime.tryParse(value.toString());
}
