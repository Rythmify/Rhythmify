import '../../../../core/data/models/track_dto.dart';
import '../../../../core/domain/entities/track.dart';
import '../../domain/entities/home_data.dart';
import '../../domain/entities/hot_for_you.dart';
import '../../domain/entities/trending_by_genre_initial.dart';
import '../../domain/entities/genre_tab.dart';
import '../../domain/entities/genre_tab_tracks.dart';
import '../../domain/entities/mixed_for_you_item.dart';
import '../../domain/entities/discover_station.dart';

class HomeDto {
  static Track _parseTrack(Map<String, dynamic> json) {
    return TrackDto.fromJson({
      ...json,
      if (json['artist'] == null && json['artist_name'] != null)
        'artist': json['artist_name'],
    });
  }

  static HomeData fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>;

    return HomeData(
      hotForYou: _parseHotForYou(data['hot_for_you']),
      trendingByGenre: _parseTrendingByGenre(data['trending_by_genre']),
      moreOfWhatYouLike: (data['more_of_what_you_like']['tracks'] as List)
          .map((t) => _parseTrack(t))
          .toList(),
      mixedForYou: (data['mixed_for_you'] as List)
          .map((m) => _parseMixedForYouItem(m))
          .toList(),
      discoverWithStations: (data['discover_with_stations'] as List)
          .map((s) => _parseDiscoverStation(s))
          .toList(),
    );
  }

  static HotForYou _parseHotForYou(Map<String, dynamic> json) {
    return HotForYou(
      track: _parseTrack(json['track']),
      reason: json['reason'] as String? ?? '',
      validUntil: DateTime.parse(json['valid_until'] as String),
    );
  }

  static TrendingByGenreInitial _parseTrendingByGenre(
    Map<String, dynamic> json,
  ) {
    return TrendingByGenreInitial(
      genres: (json['genres'] as List)
          .map(
            (g) => GenreTab(
              genreId: g['genre_id'] as String,
              genreName: g['genre_name'] as String,
            ),
          )
          .toList(),
      initialTab: _parseGenreTabTracks(json['initial_tab']),
    );
  }

  static GenreTabTracks _parseGenreTabTracks(Map<String, dynamic> json) {
    return GenreTabTracks(
      genreId: json['genre_id'] as String,
      genreName: json['genre_name'] as String,
      tracks: (json['tracks'] as List).map((t) => _parseTrack(t)).toList(),
    );
  }

  static GenreTabTracks genreTabTracksFromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>;
    return _parseGenreTabTracks(data);
  }

  static MixedForYouItem _parseMixedForYouItem(Map<String, dynamic> json) {
    return MixedForYouItem(
      id: json['id'] as String,
      label: json['label'] as String,
      flavor: json['flavor'] as String,
      genreName: json['genre_name'] as String? ?? '',
      coverImage: json['cover_image'] as String? ?? '',
      trackCount: json['track_count'] as int? ?? 0,
      generatedAt: DateTime.parse(json['generated_at'] as String),
      previewTrack: _parseTrack(json['preview_track']),
    );
  }

  static DiscoverStation _parseDiscoverStation(Map<String, dynamic> json) {
    return DiscoverStation(
      id: json['id'] as String,
      name: json['name'] as String,
      artistId: json['artist_id'] as String,
      artistName: json['artist_name'] as String? ?? '',
      coverImage: json['cover_image'] as String? ?? '',
      trackCount: json['track_count'] as int? ?? 0,
      followerCount: json['follower_count'] as int? ?? 0,
    );
  }
}
