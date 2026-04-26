import '../../../../core/network/api_client.dart';
import '../../domain/entities/top_result.dart';
import '../../../../core/data/models/track_dto.dart';
import '../../../profile/domain/entities/profile_entity.dart';
import '../../domain/entities/search_suggestion.dart';
import '../../domain/entities/search_results.dart';
import 'dart:developer' as dev;

/// Contract for the search remote data source.
abstract class SearchRemoteSource {
  /// Returns autocomplete suggestions matching [query].
  Future<List<SearchSuggestion>> getSuggestions(String query);

  /// Returns full search results across all content types for [query].
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
        avatarUrl: map['profile_picture'] as String?,
      );
    }).toList();

    return [...userSuggestions, ...suggestions];
  }

  @override
  Future<SearchResults> getSearchResults(String query) async {
    final response = await _dio.get(
      '/search',
      queryParameters: {'q': query, 'type': 'everything'},
    );
    dev.log('Search response: ${response.data}', name: 'SearchDatasource');
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
      final artworkUrl =
          (map['cover_image'] as String?) ?? firstTrackCover; // ← changed
      return <String, String>{
        'id': map['id'] as String? ?? '',
        'title': map['title'] as String? ?? '',
        'creator': owner['display_name'] as String? ?? '',
        'trackCount': (map['track_count'] as int? ?? 0).toString(),
        'artworkUrl': artworkUrl, // ← changed
      };
    }).toList();

    final albums = (data['albums'] as List? ?? []).map((a) {
      final map = a as Map<String, dynamic>;
      final releaseDate = map['release_date'] as String? ?? '';
      final year = releaseDate.length >= 4 ? releaseDate.substring(0, 4) : '';
      final previewTracks = map['preview_tracks'] as List? ?? [];
      final firstTrackCover = previewTracks.isNotEmpty
          ? (previewTracks.first as Map<String, dynamic>)['cover_image']
                    as String? ??
                ''
          : '';
      return <String, String>{
        'id': map['id'] as String? ?? '',
        'title': map['title'] as String? ?? '',
        'artist':
            (map['owner'] as Map<String, dynamic>?)?['display_name']
                as String? ??
            '',
        'artworkUrl': map['cover_image'] as String? ?? firstTrackCover,
        'year': year,
        'type': map['subtype'] as String? ?? 'Album',
      };
    }).toList();
    TopResult? topResult;

    final topTrackRaw = data['top_track'] as Map<String, dynamic>?;
    final topUserRaw = data['top_user'] as Map<String, dynamic>?;

    final trackScore = (topTrackRaw?['score'] as num?)?.toDouble() ?? -1;
    final userScore = (topUserRaw?['score'] as num?)?.toDouble() ?? -1;

    if (topUserRaw != null && userScore >= trackScore) {
      topResult = TopResultUser(
        ProfileEntity(
          id: topUserRaw['id'] as String,
          displayName: topUserRaw['display_name'] as String? ?? '',
          username: topUserRaw['username'] as String?,
          avatarUrl: topUserRaw['profile_picture'] as String?,
          followersCount: topUserRaw['follower_count'] as int? ?? 0,
          followingCount: 0,
          tracksCount: 0,
          isFollowing: topUserRaw['is_following'] as bool? ?? false,
        ),
      );
    } else if (topTrackRaw != null) {
      topResult = TopResultTrack(
        TrackDto.fromJson({
          ...topTrackRaw,
          if (topTrackRaw['artist'] == null &&
              topTrackRaw['artist_name'] != null)
            'artist': topTrackRaw['artist_name'],
          if (topTrackRaw['genre'] == null && topTrackRaw['genre_name'] != null)
            'genre': topTrackRaw['genre_name'],
        }),
      );
    }

    return SearchResults(
      topResult: topResult,
      tracks: tracks,
      profiles: profiles,
      playlists: playlists,
      albums: albums,
    );
  }
}
