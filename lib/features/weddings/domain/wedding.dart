class Wedding {
  const Wedding({
    required this.id,
    required this.name,
    required this.location,
    required this.currentUserRole,
    required this.memberCount,
    this.weddingDate,
  });

  final int id;
  final String name;
  final DateTime? weddingDate;
  final String location;
  final String currentUserRole;
  final int memberCount;

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
    );
  }
}
