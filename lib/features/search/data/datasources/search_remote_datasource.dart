import '../../../../core/network/api_client.dart';

import '../../../../core/data/models/track_dto.dart';
import '../../../profile/domain/entities/profile_entity.dart';
import '../../domain/entities/search_suggestion.dart';
import '../../domain/entities/search_results.dart';
import 'dart:developer' as dev;

/// Contract for the search remote data source.
abstract class SearchRemoteSource {
  Future<List<SearchSuggestion>> getSuggestions(String query);
  Future<SearchResults> getSearchResults(String query);
}

/// Real HTTP implementation of [SearchRemoteSource].
class SearchRemoteSourceImpl implements SearchRemoteSource {
  final _dio = apiClient.dio;

  @override
  Future<List<SearchSuggestion>> getSuggestions(String query) async {
    final response = await _dio.get(
      '/suggestions',
      queryParameters: {'q': query},
    );
    dev.log('SUGGESTIONS RESPONSE: ${response.data}');

    final data = response.data['data'] as Map<String, dynamic>;

    final suggestions = (data['suggestions'] as List? ?? [])
        .asMap()
        .entries
        .map(
          (e) => SearchSuggestion(
            id: e.key.toString(),
            text: e.value as String,
            type: 'track',
          ),
        )
        .toList();

    final userSuggestions = (data['users'] as List? ?? []).map((u) {
      final map = u as Map<String, dynamic>;
      return SearchSuggestion(
        id: map['id'] as String,
        text: map['display_name'] as String? ?? '',
        type: 'user',
        avatarUrl: map['profile_picture'] as String?, // ← add this
      );
    }).toList();

    return [...userSuggestions, ...suggestions];
  }

  @override
  Future<SearchResults> getSearchResults(String query) async {
    final response = await _dio.get('/search', queryParameters: {'q': query});
    dev.log('SEARCH RESULTS RESPONSE: ${response.data}');
    final data = response.data['data'] as Map<String, dynamic>;

    final tracks = (data['tracks'] as List? ?? [])
        .map(
          (t) => TrackDto.fromJson({
            ...(t as Map<String, dynamic>),
            if (t['artist'] == null && t['artist_name'] != null)
              'artist': t['artist_name'],
            if (t['genre'] == null && t['genre_name'] != null)
              'genre': t['genre_name'],
          }),
        )
        .toList();

    final profiles = (data['users'] as List? ?? []).map((u) {
      final map = u as Map<String, dynamic>;
      return ProfileEntity(
        id: map['id'] as String,
        displayName: map['display_name'] as String? ?? '',
        username: map['username'] as String?,
        avatarUrl: map['profile_picture'] as String?,
        followersCount: map['follower_count'] as int? ?? 0,
        followingCount: 0,
        tracksCount: 0,
        isFollowing: map['is_following'] as bool? ?? false,
      );
    }).toList();

    final playlists = (data['playlists'] as List? ?? []).map((p) {
      final map = p as Map<String, dynamic>;
      final owner = map['owner'] as Map<String, dynamic>? ?? {};
      final previewTracks = map['preview_tracks'] as List? ?? [];
      final firstTrackCover = previewTracks.isNotEmpty
          ? (previewTracks.first as Map<String, dynamic>)['cover_image']
                    as String? ??
                ''
          : '';
      return <String, String>{
        'id': map['id'] as String? ?? '',
        'title': map['title'] as String? ?? '',
        'creator': owner['display_name'] as String? ?? '',
        'trackCount': (map['track_count'] as int? ?? 0).toString(),
        'artworkUrl': firstTrackCover,
      };
    }).toList();
    return SearchResults(
      tracks: tracks,
      profiles: profiles,
      playlists: playlists,
      albums: const [],
    );
  }
}
