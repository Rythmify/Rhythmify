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
      if (userId == 'me') {
        final webProfiles = await _getOwnWebProfilesByPlatform();
        data['instagram_url'] = webProfiles['instagram'];
        data['facebook_url'] = webProfiles['facebook'];
        data['github_url'] = webProfiles['github'];
      }
      if (kDebugMode && userId == 'me') {
        debugPrint(
          '[ProfileRemoteDatasource] /users/me raw counts: '
          'followers_count=${data['followers_count']}, '
          'following_count=${data['following_count']}, '
          'followersCount=${data['followersCount']}, '
          'followingCount=${data['followingCount']}',
        );
      }
      if (userId != 'me') {
        try {
          final statusResp = await client.dio.get(
            '/users/$userId/follow-status',
          );
          final isFollowing =
              statusResp.data['data']?['is_following'] as bool? ?? false;
          data['is_following'] = isFollowing;
        } catch (_) {
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
      if (userId == 'me') {
        return const FollowStatusModel(
          isFollowing: false,
          isFollowedBy: false,
          isBlocking: false,
          isBlockedBy: false,
        );
      }
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
    String? instagramUrl,
    String? facebookUrl,
    String? githubUrl,
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

      await _syncOwnWebProfiles(
        instagramUrl: instagramUrl,
        facebookUrl: facebookUrl,
        githubUrl: githubUrl,
      );

      final data = Map<String, dynamic>.from(response.data['data'] as Map);
      final webProfiles = await _getOwnWebProfilesByPlatform();
      data['instagram_url'] = webProfiles['instagram'];
      data['facebook_url'] = webProfiles['facebook'];
      data['github_url'] = webProfiles['github'];
      return ProfileModel.fromJson(data);
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
        data['profiles'],
        data['web_profiles'],
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

  Future<void> _syncOwnWebProfiles({
    String? instagramUrl,
    String? facebookUrl,
    String? githubUrl,
  }) async {
    final desired = <String, String>{
      if (instagramUrl != null && instagramUrl.trim().isNotEmpty)
        'instagram': instagramUrl.trim(),
      if (facebookUrl != null && facebookUrl.trim().isNotEmpty)
        'facebook': facebookUrl.trim(),
      if (githubUrl != null && githubUrl.trim().isNotEmpty)
        'github': githubUrl.trim(),
    };

    final existing = await _getOwnWebProfiles();
    final trackedPlatforms = {'instagram', 'facebook', 'github'};

    for (final platform in trackedPlatforms) {
      final existingForPlatform = existing.where((item) {
        final p = _extractWebProfilePlatform(item);
        return p == platform;
      }).toList();
      final wantedUrl = desired[platform];

      if (wantedUrl == null) {
        for (final item in existingForPlatform) {
          final profileId = _extractWebProfileId(item);
          if (profileId == null) continue;
          await client.dio.delete('/users/me/web-profiles/$profileId');
        }
        continue;
      }

      final hasWanted = existingForPlatform.any(
        (item) => _extractWebProfileUrl(item) == wantedUrl,
      );

      for (final item in existingForPlatform) {
        final profileId = _extractWebProfileId(item);
        if (profileId == null) continue;
        final url = _extractWebProfileUrl(item);
        if (!hasWanted || url != wantedUrl) {
          await client.dio.delete('/users/me/web-profiles/$profileId');
        }
      }

      if (!hasWanted) {
        await _createWebProfile(platform: platform, url: wantedUrl);
      }
    }
  }

  Future<List<Map<String, dynamic>>> _getOwnWebProfiles() async {
    final response = await client.dio.get('/users/me/web-profiles');
    return _extractListPayload(response.data);
  }

  Future<Map<String, String>> _getOwnWebProfilesByPlatform() async {
    final items = await _getOwnWebProfiles();
    final out = <String, String>{};
    for (final item in items) {
      final platform = _extractWebProfilePlatform(item);
      final url = _extractWebProfileUrl(item);
      if (platform == null || url == null) continue;
      if (platform == 'instagram' ||
          platform == 'facebook' ||
          platform == 'github') {
        out[platform] = url;
      }
    }
    return out;
  }

  Future<void> _createWebProfile({
    required String platform,
    required String url,
  }) async {
    await client.dio.post(
      '/users/me/web-profiles',
      data: {'platform': platform, 'url': url},
    );
  }

  String? _extractWebProfileId(Map<String, dynamic> item) {
    final id =
        item['profile_id'] ??
        item['id'] ??
        item['web_profile_id'] ??
        item['uuid'];
    return id?.toString();
  }

  String? _extractWebProfilePlatform(Map<String, dynamic> item) {
    final raw =
        item['type'] ??
        item['platform'] ??
        item['name'] ??
        item['provider'] ??
        item['profile_type'];
    if (raw == null) return null;
    return raw.toString().trim().toLowerCase();
  }

  String? _extractWebProfileUrl(Map<String, dynamic> item) {
    final raw =
        item['url'] ??
        item['link'] ??
        item['profile_url'] ??
        item['web_url'] ??
        item['value'];
    final value = raw?.toString().trim();
    return (value == null || value.isEmpty) ? null : value;
  }
}
