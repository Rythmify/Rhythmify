import '../../../../core/network/api_client.dart';
import '../models/feed_dto.dart';
import 'package:dio/dio.dart';
import 'dart:developer';

abstract class FeedDatasource {
  Future<List<FeedItemModel>> getFollowingFeed();
  Future<List<FeedItemModel>> getDiscoverFeed();
}

class FeedRemoteDatasourceImpl implements FeedDatasource {
  final ApiClient _client;

  FeedRemoteDatasourceImpl({required ApiClient client}) : _client = client;

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
