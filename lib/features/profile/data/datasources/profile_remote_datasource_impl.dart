import 'package:dio/dio.dart';
import 'package:mime/mime.dart';
import 'package:flutter/foundation.dart';
import '../../../../core/network/api_client.dart';
import '../models/profile_model.dart';
import '../models/profile_user_summary_model.dart';
import '../models/track_model.dart';
import '../models/follow_status_model.dart';
import 'profile_remote_datasource.dart';

// coverage:ignore-file
/// HTTP implementation of profile remote datasource operations.

class ProfileRemoteDatasourceImpl implements ProfileRemoteDatasource {
  final ApiClient client;

  ProfileRemoteDatasourceImpl({required this.client});

  @override
  Future<ProfileModel> getProfile({required String userId}) async {
    try {
      final endpoint = userId == 'me' ? '/users/me' : '/users/$userId';
      final response = await client.dio.get(endpoint);
      final data = Map<String, dynamic>.from(response.data['data'] as Map);
      if (kDebugMode && userId == 'me') {
        debugPrint(
          '[ProfileRemoteDatasource] /users/me raw counts: '
          'followers_count=${data['followers_count']}, '
          'following_count=${data['following_count']}, '
          'followersCount=${data['followersCount']}, '
          'followingCount=${data['followingCount']}',
        );
      }

      // GET /users/{id} does not include is_following — only GET /users/me does.
      // For public profiles, call the dedicated follow-status endpoint and merge
      // the result so the Follow button and follower counts are always accurate.
      if (userId != 'me') {
        try {
          final statusResp = await client.dio.get(
            '/users/$userId/follow-status',
          );
          final isFollowing =
              statusResp.data['data']?['is_following'] as bool? ?? false;
          data['is_following'] = isFollowing;
        } catch (_) {
          // Unauthenticated or network error — default to false.
          data['is_following'] = data['is_following'] ?? false;
        }
      }

      return ProfileModel.fromJson(data);
    } on DioException catch (e) {
      _handleDioError(e);
      rethrow;
    }
  }

  @override
  Future<FollowStatusModel> getFollowStatus(String userId) async {
    try {
      final response = await client.dio.get('/users/$userId/follow-status');
      return FollowStatusModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      _handleDioError(e);
      rethrow;
    }
  }

  @override
  Future<ProfileModel> updateProfile({
    required String displayName,
    required String username,
    required String firstName,
    required String lastName,
    required String city,
    required String country,
    required String bio,
  }) async {
    try {
      final response = await client.dio.patch(
        '/users/me',
        data: {
          'display_name': displayName,
          'username': username,
          'first_name': firstName,
          'last_name': lastName,
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
      final mimeType = lookupMimeType(filePath) ?? 'image/jpeg';
      final formData = FormData.fromMap({
        'avatar': await MultipartFile.fromFile(
          filePath,
          contentType: DioMediaType.parse(mimeType),
        ),
      });

      await client.dio.post('/users/me/avatar', data: formData);

      // Reload full profile to get updated avatar URL
      final profile = await getProfile(userId: 'me');

      return profile;
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
      final mimeType = lookupMimeType(filePath) ?? 'image/jpeg';
      final formData = FormData.fromMap({
        'cover': await MultipartFile.fromFile(
          filePath,
          contentType: DioMediaType.parse(mimeType),
        ),
      });

      await client.dio.post('/users/me/cover', data: formData);

      // Reload full profile to get updated cover URL
      final profile = await getProfile(userId: 'me');

      return profile;
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
  Future<void> blockUser({required String userId}) async {
    try {
      await client.dio.post('/users/$userId/block');
    } on DioException catch (e) {
      _handleDioError(e);
      rethrow;
    }
  }

  @override
  Future<void> unblockUser({required String userId}) async {
    try {
      await client.dio.delete('/users/$userId/block');
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
          ? '/me/liked-tracks'
          : '/users/$userId/liked-tracks';

      final response = await client.dio.get(
        endpoint,
        queryParameters: {'page': page, 'limit': limit},
      );

      final tracks = _extractListPayload(response.data);
      return tracks
          .map((t) => TrackModel.fromJson({...t, 'is_liked': true}))
          .toList();
    } on DioException catch (e) {
      _handleDioError(e);
      rethrow;
    }
  }

  @override
  Future<List<TrackModel>> getUploadedTracks({
    required String userId,
    required int page,
    required int limit,
  }) async {
    try {
      final endpoint = userId == 'me' ? '/tracks/me' : '/users/$userId/tracks';

      final response = await client.dio.get(
        endpoint,
        queryParameters: {'page': page, 'limit': limit},
      );

      final tracks = _extractListPayload(response.data);
      return tracks.map((t) => TrackModel.fromJson(t)).toList();
    } on DioException catch (e) {
      _handleDioError(e);
      rethrow;
    }
  }

  @override
  Future<List<TrackModel>> getRepostedTracks({
    required String userId,
    required int page,
    required int limit,
  }) async {
    try {
      final endpoint = userId == 'me'
          ? '/me/reposted-tracks'
          : '/users/$userId/reposted-tracks';

      final response = await client.dio.get(
        endpoint,
        queryParameters: {'page': page, 'limit': limit},
      );
      final tracks = _extractListPayload(response.data);
      return tracks.map((t) => TrackModel.fromJson(t)).toList();
    } on DioException catch (e) {
      _handleDioError(e);
      rethrow;
    }
  }

  @override
  Future<List<ProfileUserSummaryModel>> getFollowers({
    required String userId,
    required int page,
    required int limit,
  }) async {
    try {
      final response = await client.dio.get(
        '/users/$userId/followers',
        queryParameters: {'page': page, 'limit': limit},
      );
      final users = _extractListPayload(response.data);
      return users
          .map(
            (user) => ProfileUserSummaryModel.fromJson(
              Map<String, dynamic>.from(user as Map),
              isFollowing: false,
            ),
          )
          .toList();
    } on DioException catch (e) {
      _handleDioError(e);
      rethrow;
    }
  }

  @override
  Future<List<ProfileUserSummaryModel>> getFollowing({
    required String userId,
    required int page,
    required int limit,
  }) async {
    try {
      final response = await client.dio.get(
        '/users/$userId/following',
        queryParameters: {'page': page, 'limit': limit},
      );
      final users = _extractListPayload(response.data);
      return users
          .map(
            (user) => ProfileUserSummaryModel.fromJson(
              Map<String, dynamic>.from(user as Map),
              isFollowing: true,
            ),
          )
          .toList();
    } on DioException catch (e) {
      _handleDioError(e);
      rethrow;
    }
  }

  void _handleDioError(DioException e) {
    final contentType = e.response?.headers.value('content-type') ?? '';
    if (contentType.contains('text/html')) {
      throw Exception('Cannot connect to backend. Check IP and server status.');
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

  /// Extracts a list payload from API responses that may be wrapped.
  ///
  /// Supports both:
  /// - `{ "data": [ ... ] }`
  /// - `{ "data": { "items": [ ... ] } }` and common key variants.
  List<Map<String, dynamic>> _extractListPayload(dynamic rawResponse) {
    if (rawResponse is! Map<String, dynamic>) {
      return const [];
    }

    final data = rawResponse['data'];
    if (data is List) {
      return data
          .whereType<Map>()
          .map((e) => Map<String, dynamic>.from(e))
          .toList();
    }

    if (data is Map<String, dynamic>) {
      final candidates = <dynamic>[
        data['items'],
        data['results'],
        data['users'],
        data['tracks'],
        data['followers'],
        data['following'],
        data['data'],
      ];
      for (final candidate in candidates) {
        if (candidate is List) {
          return candidate
              .whereType<Map>()
              .map((e) => Map<String, dynamic>.from(e))
              .toList();
        }
      }
    }

    return const [];
  }
}
