import 'package:hitched/core/models/wedding_models.dart';

class AuthApiException implements Exception {
  const AuthApiException(this.message);
  final String message;

  @override
  String toString() => message;
}

class AuthApi {
  AuthApi({Object? client, String? baseUrl});

  Future<AppUser> login({
    required String email,
    required String password,
  }) async {
    final normalizedEmail = email.trim().toLowerCase();
    if (normalizedEmail.isEmpty || password.isEmpty) {
      throw const AuthApiException('Email and password are required');
    }
    return _demoUsers[normalizedEmail] ??
        _localUser(
          id: 'local-${normalizedEmail.hashCode.abs()}',
          name: _nameFromEmail(normalizedEmail),
          email: normalizedEmail,
          role: _roleFromEmail(normalizedEmail),
        );
  }

  Future<AppUser> registerCouple({
    required UserRole role,
    required String name,
    required String email,
    required String password,
    required String partnerName,
    required String partnerEmail,
    required String partnerPassword,
    required String weddingDate,
    required String location,
  }) async {
    final normalizedEmail = email.trim().toLowerCase();
    if (name.trim().isEmpty || normalizedEmail.isEmpty || password.isEmpty) {
      throw const AuthApiException('Name, email, and password are required');
    }
    return _localUser(
      id: 'local-${normalizedEmail.hashCode.abs()}',
      coupleId: 'couple-local',
      name: name.trim(),
      email: normalizedEmail,
      role: role,
    );
  }

  Future<AppUser> registerVendor({
    required String ownerName,
    required String email,
    required String password,
    required String serviceName,
    required VendorCategory category,
    required String description,
    required int priceCents,
    required String imageUrl,
  }) async {
    final normalizedEmail = email.trim().toLowerCase();
    if (ownerName.trim().isEmpty ||
        normalizedEmail.isEmpty ||
        password.isEmpty ||
        serviceName.trim().isEmpty) {
      throw const AuthApiException(
        'Owner name, email, password, and service name are required',
      );
    }
    return _localUser(
      id: 'vendor-${normalizedEmail.hashCode.abs()}',
      name: ownerName.trim(),
      email: normalizedEmail,
      role: UserRole.vendor,
    );
  }

  AppUser _localUser({
    required String id,
    required String name,
    required String email,
    required UserRole role,
    String? coupleId,
  }) {
    return AppUser(
      id: id,
      coupleId: coupleId ?? (role == UserRole.vendor ? null : 'couple-1'),
      name: name,
      email: email,
      role: role,
      token: 'local-auth-token',
    );
  }

  String _nameFromEmail(String email) {
    final localPart = email.split('@').first;
    if (localPart.isEmpty) return 'Hitched User';
    return localPart
        .split(RegExp(r'[._-]+'))
        .where((part) => part.isNotEmpty)
        .map((part) => '${part[0].toUpperCase()}${part.substring(1)}')
        .join(' ');
  }

  UserRole _roleFromEmail(String email) {
    if (email.contains('vendor')) return UserRole.vendor;
    if (email.contains('groom')) return UserRole.groom;
    if (email.contains('admin')) return UserRole.admin;
    return UserRole.bride;
  }
}

final _demoUsers = <String, AppUser>{
  'bride@hitched.app': const AppUser(
    id: 'bride-1',
    coupleId: 'couple-1',
    name: 'Amara Belle',
    email: 'bride@hitched.app',
    role: UserRole.bride,
    token: 'local-auth-token',
  ),
  'groom@hitched.app': const AppUser(
    id: 'groom-1',
    coupleId: 'couple-1',
    name: 'Daniel Hart',
    email: 'groom@hitched.app',
    role: UserRole.groom,
    token: 'local-auth-token',
  ),
  'vendor@hitched.app': const AppUser(
    id: 'vendor-1',
    name: 'Tara Studios',
    email: 'vendor@hitched.app',
    role: UserRole.vendor,
    token: 'local-auth-token',
  ),
};
