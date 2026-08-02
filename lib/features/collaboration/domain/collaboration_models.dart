import '../../weddings/domain/wedding.dart';

enum WeddingInvitationStatus {
  pending('pending', 'Pending'),
  accepted('accepted', 'Accepted'),
  revoked('revoked', 'Revoked'),
  expired('expired', 'Expired');

  const WeddingInvitationStatus(this.apiValue, this.label);
  final String apiValue;
  final String label;

  static WeddingInvitationStatus fromApi(String value) {
    return values.firstWhere((status) => status.apiValue == value);
  }
}

class WeddingInvitation {
  const WeddingInvitation({
    required this.id,
    required this.weddingId,
    required this.email,
    required this.token,
    required this.status,
    required this.expiresAt,
    required this.createdAt,
    this.invitedBy,
    this.acceptedBy,
    this.acceptedAt,
    this.revokedAt,
  });

  final int id;
  final int weddingId;
  final String email;
  final String token;
  final WeddingInvitationStatus status;
  final WeddingMemberUser? invitedBy;
  final WeddingMemberUser? acceptedBy;
  final DateTime expiresAt;
  final DateTime? acceptedAt;
  final DateTime? revokedAt;
  final DateTime createdAt;

  factory WeddingInvitation.fromJson(Map<String, dynamic> json) {
    return WeddingInvitation(
      id: json['id'] as int,
      weddingId: json['wedding'] as int,
      email: json['email'] as String,
      token: json['token'] as String,
      status: WeddingInvitationStatus.fromApi(json['status'] as String),
      invitedBy: _user(json['invited_by']),
      acceptedBy: _user(json['accepted_by']),
      expiresAt: DateTime.parse(json['expires_at'] as String).toLocal(),
      acceptedAt: _date(json['accepted_at']),
      revokedAt: _date(json['revoked_at']),
      createdAt: DateTime.parse(json['created_at'] as String).toLocal(),
    );
  }
}

class WeddingInvitationPreview {
  const WeddingInvitationPreview({
    required this.email,
    required this.weddingId,
    required this.weddingName,
    required this.location,
    required this.status,
    required this.expiresAt,
    this.weddingDate,
  });

  final String email;
  final int weddingId;
  final String weddingName;
  final DateTime? weddingDate;
  final String location;
  final WeddingInvitationStatus status;
  final DateTime expiresAt;

  bool get canAccept => status == WeddingInvitationStatus.pending;

  factory WeddingInvitationPreview.fromJson(Map<String, dynamic> json) {
    return WeddingInvitationPreview(
      email: json['email'] as String,
      weddingId: json['wedding_id'] as int,
      weddingName: json['wedding_name'] as String,
      weddingDate: _date(json['wedding_date']),
      location: json['location'] as String? ?? '',
      status: WeddingInvitationStatus.fromApi(json['status'] as String),
      expiresAt: DateTime.parse(json['expires_at'] as String).toLocal(),
    );
  }
}

WeddingMemberUser? _user(dynamic value) {
  return value is Map
      ? WeddingMemberUser.fromJson(Map<String, dynamic>.from(value))
      : null;
}

DateTime? _date(dynamic value) {
  return value == null ? null : DateTime.tryParse(value.toString())?.toLocal();
}
