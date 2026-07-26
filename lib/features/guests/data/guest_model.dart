class Guest {
  final int id;
  final String name;
  final String? email;
  final String rsvpStatus;
  final String? dietaryNotes;

  Guest({
    required this.id,
    required this.name,
    this.email,
    required this.rsvpStatus,
    this.dietaryNotes,
  });

  factory Guest.fromJson(Map<String, dynamic> json) {
    return Guest(
      id: json['id'] as int,
      name: json['name'] as String,
      email: json['email'] as String?,
      rsvpStatus: json['rsvpStatus'] as String,
      dietaryNotes: json['dietaryNotes'] as String?,
    );
  }
}
