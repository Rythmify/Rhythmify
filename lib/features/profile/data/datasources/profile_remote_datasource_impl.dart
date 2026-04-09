import 'package:dio/dio.dart';
import 'package:mime/mime.dart';
import '../../../../core/network/api_client.dart';
import '../models/profile_model.dart';
import '../models/track_model.dart';
import 'profile_remote_datasource.dart';

class ProfileRemoteDatasourceImpl implements ProfileRemoteDatasource {
  final ApiClient client;

  ProfileRemoteDatasourceImpl({required this.client});

  String _profileReadEndpoint(String userId) {
    return userId == 'me' ? '/users/me' : '/users/$userId';
  }

  String _profileWriteEndpoint() {
    return '/users/me';
  }

  @override
  Future<ProfileModel> getProfile({required String userId}) async {
    try {
      final response = await client.dio.get(_profileReadEndpoint(userId));

      return ProfileModel.fromJson(response.data['data']);
    } on DioException catch (e) {
      _handleDioError(e);
      rethrow;
    }
  }

  @override
  Future<ProfileModel> updateProfile({
    required String userId,
    required String displayName,
    required String city,
    required String country,
    required String bio,
  }) async {
    try {
      final response = await client.dio.patch(
        _profileWriteEndpoint(),
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
  Future<ProfileModel> uploadAvatar({
    required String userId,
    required String filePath,
  }) async {
    try {
      print('🔵 uploadAvatar: Starting upload for file: $filePath');
      print('🔵 uploadAvatar: User ID: $userId');

      final mimeType = lookupMimeType(filePath) ?? 'image/jpeg';
      print('🔵 uploadAvatar: MIME type: $mimeType');

      final formData = FormData.fromMap({
        'avatar': await MultipartFile.fromFile(
          filePath,
          contentType: DioMediaType.parse(mimeType),
        ),
      });

      final endpoint = '${_profileWriteEndpoint()}/avatar';
      print('🔵 uploadAvatar: Sending POST to $endpoint');
      final response = await client.dio.post(endpoint, data: formData);
      print(
        '🟢 uploadAvatar: Upload successful! Status: ${response.statusCode}',
      );

      // Reload full profile to get updated avatar URL
      print('🔵 uploadAvatar: Reloading profile to get new avatar URL');
      final profile = await getProfile(userId: userId);
      print(
        '🟢 uploadAvatar: Profile reloaded. Avatar URL: ${profile.avatarUrl}',
      );

      return profile;
    } on DioException catch (e) {
      print('🔴 uploadAvatar: DioException occurred');
      print('🔴 Status code: ${e.response?.statusCode}');
      print('🔴 Response data: ${e.response?.data}');
      print('🔴 Error message: ${e.message}');
      _handleDioError(e);
      rethrow;
    } catch (e) {
      print('🔴 uploadAvatar: Unexpected error: $e');
      rethrow;
    }
  }

  @override
  Future<void> deleteAvatar({required String userId}) async {
    try {
      final endpoint = '${_profileWriteEndpoint()}/avatar';
      await client.dio.delete(endpoint);
    } on DioException catch (e) {
      _handleDioError(e);
      rethrow;
    }
  }

  @override
  Future<ProfileModel> uploadCoverPhoto({
    required String userId,
    required String filePath,
  }) async {
    try {
      final mimeType = lookupMimeType(filePath) ?? 'image/jpeg';
      final formData = FormData.fromMap({
        'cover': await MultipartFile.fromFile(
          filePath,
          contentType: DioMediaType.parse(mimeType),
        ),
      });

      final endpoint = '${_profileWriteEndpoint()}/cover';
      await client.dio.post(endpoint, data: formData);

      // Reload full profile to get updated cover URL
      final profile = await getProfile(userId: userId);

      return profile;
    } on DioException catch (e) {
      _handleDioError(e);
      rethrow;
    }
  }

  @override
  Future<void> deleteCoverPhoto({required String userId}) async {
    try {
      final endpoint = '${_profileWriteEndpoint()}/cover';
      await client.dio.delete(endpoint);
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
      final endpoint = userId == 'me'
          ? '/users/me/tracks'
          : '/users/$userId/tracks';
      final response = await client.dio.get(
        endpoint,
        queryParameters: {'page': page, 'limit': limit},
      );

      final List<dynamic> tracks = response.data['data'];
      return tracks.map((t) => TrackModel.fromJson(t)).toList();
    } on DioException catch (e) {
      _handleDioError(e);
      rethrow;
    }
  }

  void _handleDioError(DioException e) {
    final contentType = e.response?.headers.value('content-type') ?? '';
    if (contentType.contains('text/html')) {
      final method = e.requestOptions.method;
      final path = e.requestOptions.path;
      throw Exception('ROUTE_NOT_FOUND: $method $path');
    }

    final errorCode = e.response?.data?['error']?['code'] as String?;
    final errorMessage = e.response?.data?['error']?['message'] as String?;
    switch (errorCode) {
      case 'RESOURCE_NOT_FOUND':
        throw Exception('PROFILE_NOT_FOUND');
      case 'RESOURCE_PRIVATE':
        throw Exception('PROFILE_NOT_FOUND');
      case 'UPLOAD_FILE_TOO_LARGE':
        throw Exception('UPLOAD_FILE_TOO_LARGE');
      case 'UPLOAD_INVALID_FILE_TYPE':
        throw Exception('UPLOAD_INVALID_FILE_TYPE');
      case 'PERMISSION_DENIED':
        throw Exception('PERMISSION_DENIED');
      case 'FOLLOW_SELF':
        throw Exception('FOLLOW_SELF');
      case 'RATE_LIMIT_EXCEEDED':
        throw Exception('RATE_LIMIT_EXCEEDED');
      case 'VALIDATION_FAILED':
        throw Exception(errorMessage ?? 'VALIDATION_FAILED');
      default:
        throw Exception(errorMessage ?? 'Unknown error occurred');
    }
  }
}
