import '../../../../core/network/api_client.dart';
import '../models/feed_dto.dart';
import 'package:dio/dio.dart';
import 'dart:developer';

/// Abstract contract for fetching feed data from a data source.
///
/// Defines the two core feed endpoints: the personalized following feed
/// and the algorithm-driven discovery feed.
abstract class FeedDatasource {
  /// Fetches the authenticated user's following feed.
  ///
  /// Returns a list of [FeedItemModel] representing activity from
  /// users the current user follows.
  Future<List<FeedItemModel>> getFollowingFeed();

  /// Fetches the discovery feed for the authenticated user.
  ///
  /// Returns a list of [FeedItemModel] surfaced by the recommendation
  /// algorithm, independent of who the user follows.
  Future<List<FeedItemModel>> getDiscoverFeed();
}

/// Remote implementation of [FeedDatasource] that fetches feed data
/// from the Rythmify backend API.
///
/// Uses [ApiClient] to perform authenticated HTTP requests and maps
/// raw JSON responses into typed [FeedItemModel] instances.
class FeedRemoteDatasourceImpl implements FeedDatasource {
  final ApiClient _client;

  /// Creates a [FeedRemoteDatasourceImpl] with the given [ApiClient].
  FeedRemoteDatasourceImpl({required ApiClient client}) : _client = client;

  /// Fetches the following feed from `GET /feed`.
  ///
  /// Attaches a Bearer token to the request, then maps each item in the
  /// response `data` array through [_parseItem]. Items that fail to parse
  /// (i.e. return `null`) are filtered out via [Iterable.whereType].
  @override
  Future<List<FeedItemModel>> getFollowingFeed() async {
    final token = await _client.getToken();
    final response = await _client.dio.get(
      '/feed',
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );
    log('Feed response: ${response.data}', name: 'FeedDatasource');
    final List<dynamic> data = response.data['data'] as List<dynamic>;
    return data
        .map((e) => _parseItem(e as Map<String, dynamic>))
        .whereType<FeedItemModel>()
        .toList();
  }

  /// Fetches the discovery feed from `GET /feed/discovery`.
  ///
  /// Attaches a Bearer token to the request, then maps each item in the
  /// response `data` array through [_parseDiscoverItem]. Items that fail
  /// to parse are filtered out. Returns an empty list on any error.
  @override
  Future<List<FeedItemModel>> getDiscoverFeed() async {
    try {
      final token = await _client.getToken();
      final response = await _client.dio.get(
        '/feed/discovery',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      log('Discover feed response: ${response.data}', name: 'FeedDatasource');
      final List<dynamic> data = response.data['data'] as List<dynamic>;
      return data
          .map((e) => _parseDiscoverItem(e as Map<String, dynamic>))
          .whereType<FeedItemModel>()
          .toList();
    } catch (_) {
      return [];
    }
  }

  /// Parses a single following-feed JSON object into a [FeedItemModel].
  ///
  /// Resolves the track to display by preferring the top-level `track` field,
  /// falling back to the first track inside a `playlist` if present.
  /// Returns `null` if no resolvable track is found.
  ///
  /// The track owner is resolved in order: `track.user` → `track.artist` → `user`.
  FeedItemModel? _parseItem(Map<String, dynamic> json) {
    final trackJson = json['track'] as Map<String, dynamic>?;
    final playlistJson = json['playlist'] as Map<String, dynamic>?;
    final userJson = json['user'] as Map<String, dynamic>;

    final resolvedTrack =
        trackJson ??
        (playlistJson?['tracks'] as List<dynamic>?)
            ?.whereType<Map<String, dynamic>>()
            .firstOrNull;

    if (resolvedTrack == null) return null;

    final trackOwnerJson =
        resolvedTrack['user'] as Map<String, dynamic>? ??
        resolvedTrack['artist'] as Map<String, dynamic>? ??
        userJson;

    return FeedItemModel(
      id: json['id'] as String,
      type: json['type'] as String,
      contentType: json['content_type'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      user: FeedUserModel.fromJson(userJson),
      trackOwner: FeedUserModel.fromJson(trackOwnerJson),
      track: FeedTrackModel.fromJson(resolvedTrack),
      playlist: playlistJson != null
          ? FeedPlaylistModel.fromJson(playlistJson)
          : null,
    );
  }

  /// Parses a single discovery-feed JSON object into a [FeedItemModel].
  ///
  /// Returns `null` if the `track` field is missing. Extracts the
  /// recommendation [discoverLabel] from `reason.label`, defaulting to
  /// `'Discovered for you'` if absent. Constructs the [FeedUserModel]
  /// for both [FeedItemModel.user] and [FeedItemModel.trackOwner] directly
  /// from the track's `artist` object, since discovery items have no
  /// separate posting user.
  FeedItemModel? _parseDiscoverItem(Map<String, dynamic> json) {
    final trackJson = json['track'] as Map<String, dynamic>?;
    if (trackJson == null) return null;

    final reasonJson = json['reason'] as Map<String, dynamic>? ?? {};
    final label = reasonJson['label'] as String? ?? 'Discovered for you';
    final artistJson = trackJson['artist'] as Map<String, dynamic>? ?? {};

    final ownerUser = FeedUserModel(
      id: artistJson['id'] as String? ?? '',
      username: artistJson['username'] as String? ?? '',
      displayName: artistJson['username'] as String? ?? '',
      avatar: artistJson['profile_picture'] as String?,
      followers: 0,
      isVerified: false,
      isFollowing: artistJson['is_following'] as bool? ?? false,
    );

    return FeedItemModel(
      id: json['id'] as String,
      type: 'discover',
      contentType: 'track',
      createdAt: DateTime.now(),
      user: ownerUser, // for discover, poster = track owner
      trackOwner: ownerUser,
      track: FeedTrackModel.fromJson(trackJson),
      discoverLabel: label,
    );
  }
}
