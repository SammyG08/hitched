class AppUser {
  const AppUser({
    required this.id,
    required this.email,
    required this.firstName,
    required this.lastName,
    this.dateJoined,
  });

  final int id;
  final String email;
  final String firstName;
  final String lastName;
  final DateTime? dateJoined;

  String get fullName => '$firstName $lastName'.trim();

  factory AppUser.fromJson(Map<String, dynamic> json) {
    return AppUser(
      id: json['id'] as int,
      email: json['email'] as String,
      firstName: json['first_name'] as String? ?? '',
      lastName: json['last_name'] as String? ?? '',
      dateJoined: DateTime.tryParse(json['date_joined']?.toString() ?? ''),
    );
  }
}
