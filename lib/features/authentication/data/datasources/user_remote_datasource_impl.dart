import 'package:dio/dio.dart';
import '../models/user_model.dart';
import 'user_remote_datasource.dart';
import '../../../../core/network/api_client.dart';

/// Real HTTP implementation of [UserRemoteDatasource].
///
/// Makes all network requests via the [ApiClient] Dio instance.
/// Communicates with the custom Node.js REST API at
/// `{baseUrl}/users/*`.
///
/// All methods throw typed [Exception]s on failure (not [Either]).
/// The repository implementation should catch these
/// and map them to the appropriate [Failure] subclass.
class UserRemoteDatasourceImpl implements UserRemoteDatasource {
  /// The API client used to make authenticated HTTP requests.
  final ApiClient client;

  /// Creates a [UserRemoteDatasourceImpl] with the given [client].
  UserRemoteDatasourceImpl({required this.client});

  /// Fetches the current authenticated user's profile via `GET /users/me`.
  ///
  /// Returns a [UserModel] with complete profile information including:
  /// - Basic identity (id, email, displayName)
  /// - Profile details (username, bio, location)
  /// - Media (avatarUrl, coverUrl)
  /// - Statistics (followersCount, followingCount, tracksCount)
  /// - Verification status
  ///
  /// This method is designed to be called after any login (email, Google, Apple)
  /// to sync the user's complete profile data with the app state.
  ///
  /// Throws typed [Exception]s via [_handleDioError] on failure:
  /// - `RESOURCE_NOT_FOUND` — user profile not found.
  /// - `PERMISSION_DENIED` — unauthorized access.
  @override
  Future<UserModel> getUserProfile() async {
    try {
      final response = await client.dio.get('/users/me');

      final data = response.data['data'];

      return UserModel.fromJson({
        'id': data['id']?.toString() ?? data['user_id']?.toString() ?? '',
        'email': data['email'],
        'display_name': data['display_name'],
        'username': data['username'],
        'avatar_url': data['profile_picture'] ?? data['avatar_url'],
        'cover_url': data['cover_photo'] ?? data['cover_url'],
        'city': data['city'],
        'country': data['country'],
        'bio': data['bio'],
        'followers_count': data['followers_count'],
        'following_count': data['following_count'],
        'tracks_count': data['tracks_count'],
        'is_verified': data['is_verified'],
        'is_email_verified': data['is_verified'] ?? data['is_email_verified'],
      });
    } on DioException catch (e) {
      _handleDioError(e);
      rethrow;
    }
  }

  /// Maps a [DioException] to a typed [Exception] with a known error code.
  ///
  /// Reads `response.data['error']['code']` and
  /// `response.data['error']['message']` from the backend error response.
  /// Falls back to the message field or `'Unknown error occurred'` when
  /// the code is not in the known list.
  ///
  /// Known codes mapped:
  /// - `RESOURCE_NOT_FOUND` — profile not found.
  /// - `PERMISSION_DENIED` — unauthorized access.
  /// - `RATE_LIMIT_EXCEEDED` — too many requests.
  void _handleDioError(DioException e) {
    final errorCode = e.response?.data?['error']?['code'] as String?;
    final errorMessage = e.response?.data?['error']?['message'] as String?;

    switch (errorCode) {
      case 'RESOURCE_NOT_FOUND':
        throw Exception('USER_PROFILE_NOT_FOUND');
      case 'PERMISSION_DENIED':
        throw Exception('PERMISSION_DENIED');
      case 'RATE_LIMIT_EXCEEDED':
        throw Exception('RATE_LIMIT_EXCEEDED');
      default:
        throw Exception(errorMessage ?? 'Unknown error occurred');
    }
  }
}
