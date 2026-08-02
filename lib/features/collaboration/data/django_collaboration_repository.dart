import 'package:dio/dio.dart';

import '../../../core/errors/api_exception.dart';
import '../../../core/network/api_client.dart';
import '../../weddings/domain/wedding.dart';
import '../domain/collaboration_models.dart';
import '../domain/collaboration_repository.dart';

class DjangoCollaborationRepository implements CollaborationRepository {
  DjangoCollaborationRepository(ApiClient apiClient) : _dio = apiClient.dio;

  final Dio _dio;

  String _invitations(int weddingId) => '/weddings/$weddingId/invitations/';

  @override
  Future<List<WeddingInvitation>> fetchMyPendingInvitations() async {
    try {
      final response = await _dio.get<List<dynamic>>(
        '/weddings/invitations/pending/',
      );
      return response.data!
          .map(
            (item) => WeddingInvitation.fromJson(
              Map<String, dynamic>.from(item as Map),
            ),
          )
          .toList(growable: false);
    } on DioException catch (error) {
      throw ApiException.fromDio(error);
    }
  }

  @override
  Future<List<WeddingInvitation>> fetchInvitations(int weddingId) async {
    try {
      final response = await _dio.get<List<dynamic>>(_invitations(weddingId));
      return response.data!
          .map(
            (item) => WeddingInvitation.fromJson(
              Map<String, dynamic>.from(item as Map),
            ),
          )
          .toList(growable: false);
    } on DioException catch (error) {
      throw ApiException.fromDio(error);
    }
  }

  @override
  Future<WeddingInvitation> createInvitation(
    int weddingId,
    String email,
  ) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        _invitations(weddingId),
        data: {'email': email.trim()},
      );
      return WeddingInvitation.fromJson(response.data!);
    } on DioException catch (error) {
      throw ApiException.fromDio(error);
    }
  }

  @override
  Future<void> revokeInvitation(int weddingId, int invitationId) async {
    try {
      await _dio.delete<void>('${_invitations(weddingId)}$invitationId/');
    } on DioException catch (error) {
      throw ApiException.fromDio(error);
    }
  }

  @override
  Future<WeddingInvitationPreview> previewInvitation(String token) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        '/weddings/invitations/$token/',
      );
      return WeddingInvitationPreview.fromJson(response.data!);
    } on DioException catch (error) {
      throw ApiException.fromDio(error);
    }
  }

  @override
  Future<WeddingMember> acceptInvitation(String token) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        '/weddings/invitations/$token/accept/',
        data: const <String, dynamic>{},
      );
      return WeddingMember.fromJson(response.data!);
    } on DioException catch (error) {
      throw ApiException.fromDio(error);
    }
  }
}
