import 'package:dio/dio.dart';
import '../../../../core/network/api_client.dart';
import '../models/profile_model.dart';
import '../models/track_model.dart';
import 'profile_remote_datasource.dart';

class ProfileRemoteDatasourceImpl implements ProfileRemoteDatasource {
  final ApiClient client;

  ProfileRemoteDatasourceImpl({required this.client});

  @override
  Future<ProfileModel> getProfile({required String userId}) async {
    try {
      final response = await client.dio.get('/users/$userId');
      return ProfileModel.fromJson(response.data['data']);
    } on DioException catch (e) {
      _handleDioError(e);
      rethrow;
    }
  }

  @override
  Future<ProfileModel> updateProfile({
    required String displayName,
    required String city,
    required String country,
    required String bio,
  }) async {
    try {
      final response = await client.dio.patch(
        '/users/me',
        data: {
          'display_name': displayName,
          'city': city,
          'country': country,
          'bio': bio,
        },
      );
      return ProfileModel.fromJson(response.data['data']);
    } on DioException catch (e) {
      _handleDioError(e);
      rethrow;
    }
  }

  @override
  Future<ProfileModel> uploadAvatar({required String filePath}) async {
    try {
      // multipart/form-data — Dio handles Content-Type automatically
      final formData = FormData.fromMap({
        'avatar': await MultipartFile.fromFile(filePath),
      });

      final response = await client.dio.post(
        '/users/me/avatar',
        data: formData,
      );
      return ProfileModel.fromJson(response.data['data']);
    } on DioException catch (e) {
      _handleDioError(e);
      rethrow;
    }
  }

  @override
  Future<void> deleteAvatar() async {
    try {
      await client.dio.delete('/users/me/avatar');
    } on DioException catch (e) {
      _handleDioError(e);
      rethrow;
    }
  }

  @override
  Future<ProfileModel> uploadCoverPhoto({required String filePath}) async {
    try {
      final formData = FormData.fromMap({
        'cover': await MultipartFile.fromFile(filePath),
      });

      final response = await client.dio.post(
        '/users/me/cover',
        data: formData,
      );
      return ProfileModel.fromJson(response.data['data']);
    } on DioException catch (e) {
      _handleDioError(e);
      rethrow;
    }
  }

  @override
  Future<void> deleteCoverPhoto() async {
    try {
      await client.dio.delete('/users/me/cover');
    } on DioException catch (e) {
      _handleDioError(e);
      rethrow;
    }
  }

  @override
  Future<void> followUser({required String userId}) async {
    try {
      await client.dio.post('/users/$userId/follow');
    } on DioException catch (e) {
      _handleDioError(e);
      rethrow;
    }
  }

  @override
  Future<void> unfollowUser({required String userId}) async {
    try {
      await client.dio.delete('/users/$userId/follow');
    } on DioException catch (e) {
      _handleDioError(e);
      rethrow;
    }
  }

  @override
  Future<List<TrackModel>> getLikedTracks({
    required String userId,
    required int page,
    required int limit,
  }) async {
    try {
      final response = await client.dio.get(
        '/users/$userId/tracks',
        queryParameters: {
          'page': page,
          'limit': limit,
        },
      );

      final List<dynamic> tracks = response.data['data'];
      return tracks.map((t) => TrackModel.fromJson(t)).toList();
    } on DioException catch (e) {
      _handleDioError(e);
      rethrow;
    }
  }

  // ── Error handler ─────────────────────────────────
  void _handleDioError(DioException e) {
    final errorCode = e.response?.data?['error']?['code'] as String?;
    final errorMessage = e.response?.data?['error']?['message'] as String?;

    switch (errorCode) {
      case 'RESOURCE_NOT_FOUND':
        throw Exception('PROFILE_NOT_FOUND');
      case 'UPLOAD_FILE_TOO_LARGE':
        throw Exception('UPLOAD_FILE_TOO_LARGE');
      case 'UPLOAD_INVALID_FILE_TYPE':
        throw Exception('UPLOAD_INVALID_FILE_TYPE');
      case 'PERMISSION_DENIED':
        throw Exception('PERMISSION_DENIED');
      case 'RATE_LIMIT_EXCEEDED':
        throw Exception('RATE_LIMIT_EXCEEDED');
      default:
        throw Exception(errorMessage ?? 'Unknown error occurred');
    }
  }
}