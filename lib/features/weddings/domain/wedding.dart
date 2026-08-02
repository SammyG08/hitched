class Wedding {
  const Wedding({
    required this.id,
    required this.name,
    required this.location,
    required this.currentUserRole,
    required this.memberCount,
    this.weddingDate,
    this.members = const [],
  });

  final int id;
  final String name;
  final DateTime? weddingDate;
  final String location;
  final String currentUserRole;
  final int memberCount;
  final List<WeddingMember> members;

  bool get isOwner => currentUserRole == 'owner';

  factory Wedding.fromJson(Map<String, dynamic> json) {
    final memberships = json['memberships'];
    return Wedding(
      id: json['id'] as int,
      name: json['name'] as String,
      weddingDate: DateTime.tryParse(json['wedding_date']?.toString() ?? ''),
      location: json['location'] as String? ?? '',
      currentUserRole: json['current_user_role'] as String? ?? 'partner',
      memberCount: memberships is List ? memberships.length : 0,
      members: memberships is List
          ? memberships
                .map(
                  (item) => WeddingMember.fromJson(
                    Map<String, dynamic>.from(item as Map),
                  ),
                )
                .toList(growable: false)
          : const [],
    );
  }
}

class WeddingMember {
  const WeddingMember({
    required this.id,
    required this.user,
    required this.role,
  });

  final int id;
  final WeddingMemberUser user;
  final String role;

  factory WeddingMember.fromJson(Map<String, dynamic> json) {
    return WeddingMember(
      id: json['id'] as int,
      user: WeddingMemberUser.fromJson(
        Map<String, dynamic>.from(json['user'] as Map),
      ),
      role: json['role'] as String,
    );
  }
}

class WeddingMemberUser {
  const WeddingMemberUser({
    required this.id,
    required this.email,
    required this.firstName,
    required this.lastName,
  });

  final int id;
  final String email;
  final String firstName;
  final String lastName;

  String get displayName => '$firstName $lastName'.trim().isEmpty
      ? email
      : '$firstName $lastName'.trim();

  factory WeddingMemberUser.fromJson(Map<String, dynamic> json) {
    return WeddingMemberUser(
      id: json['id'] as int,
      email: json['email'] as String,
      firstName: json['first_name'] as String? ?? '',
      lastName: json['last_name'] as String? ?? '',
    );
  }
}
