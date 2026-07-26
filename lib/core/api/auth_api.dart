import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:hitched/core/models/wedding_models.dart';

class AuthApiException implements Exception {
  const AuthApiException(this.message);
  final String message;

  @override
  String toString() => message;
}

class AuthApi {
  AuthApi({http.Client? client, String? baseUrl})
    : _client = client ?? http.Client(),
      _baseUrl =
          baseUrl ??
          const String.fromEnvironment(
            'API_BASE_URL',
            defaultValue: 'http://localhost:8080',
          );

  final http.Client _client;
  final String _baseUrl;

  Future<AppUser> login({
    required String email,
    required String password,
  }) async {
    final json = await _post('/auth/login', {
      'email': email,
      'password': password,
    });
    return _userFromJson(json);
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
    final json = await _post('/auth/register', {
      'role': role.name,
      'name': name,
      'email': email,
      'password': password,
      'partnerName': partnerName,
      'partnerEmail': partnerEmail,
      'partnerPassword': partnerPassword,
      'weddingDate': weddingDate,
      'location': location,
    });
    return _userFromJson(json);
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
    final json = await _post('/vendors/register', {
      'name': ownerName,
      'email': email,
      'password': password,
      'serviceName': serviceName,
      'category': _backendCategory(category),
      'description': description,
      'priceCents': priceCents,
      'imageUrl': imageUrl,
    });
    return _userFromJson(json);
  }

  Future<Map<String, dynamic>> _post(
    String path,
    Map<String, dynamic> body,
  ) async {
    final response = await _client.post(
      Uri.parse('$_baseUrl$path'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );
    final decoded = response.body.isEmpty
        ? <String, dynamic>{}
        : jsonDecode(response.body) as Map<String, dynamic>;
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw AuthApiException('${decoded['error'] ?? 'Authentication failed'}');
    }
    return decoded;
  }

  AppUser _userFromJson(Map<String, dynamic> json) {
    return AppUser(
      id: '${json['id'] ?? json['vendorId'] ?? ''}',
      coupleId: json['coupleId'] == null ? null : '${json['coupleId']}',
      name: '${json['name'] ?? 'Vendor'}',
      email: '${json['email'] ?? ''}',
      role: _roleFromJson('${json['role']}'),
      token: json['token'] == null ? null : '${json['token']}',
    );
  }

  UserRole _roleFromJson(String value) => switch (value) {
    'bride' => UserRole.bride,
    'groom' => UserRole.groom,
    'vendor' => UserRole.vendor,
    'admin' => UserRole.admin,
    _ => UserRole.bride,
  };

  String _backendCategory(VendorCategory category) => switch (category) {
    VendorCategory.gowns => 'bridal_gown',
    VendorCategory.catering => 'catering',
    VendorCategory.venue => 'venue',
    VendorCategory.photography => 'vendor',
    VendorCategory.decor => 'vendor',
    VendorCategory.music => 'vendor',
  };
}
