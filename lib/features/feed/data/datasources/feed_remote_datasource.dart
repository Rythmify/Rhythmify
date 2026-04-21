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
    final response = await _client.dio.get('/feed/discover');
    final List<dynamic> data = response.data['data'] as List<dynamic>;
    return data
        .map((e) => _parseItem(e as Map<String, dynamic>))
        .whereType<FeedItemModel>()
        .toList();
  }

  FeedItemModel? _parseItem(Map<String, dynamic> json) {
    final trackJson = json['track'] as Map<String, dynamic>?;
    final playlistJson = json['playlist'] as Map<String, dynamic>?;

    final resolvedTrack =
        trackJson ??
        (playlistJson?['tracks'] as List<dynamic>?)
            ?.whereType<Map<String, dynamic>>()
            .firstOrNull;

    if (resolvedTrack == null) return null;

    return FeedItemModel(
      id: json['id'] as String,
      type: json['type'] as String,
      contentType: json['content_type'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      user: FeedUserModel.fromJson(json['user'] as Map<String, dynamic>),
      track: FeedTrackModel.fromJson(resolvedTrack),
      playlist: playlistJson != null
          ? FeedPlaylistModel.fromJson(playlistJson)
          : null,
    );
  }
}
