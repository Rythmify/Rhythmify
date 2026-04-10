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
  static Track parseTrack(Map<String, dynamic> json) {
    return TrackDto.fromJson({
      ...json,
      if (json['artist'] == null && json['artist_name'] != null)
        'artist': json['artist_name'],
      if (json['genre'] == null && json['genre_name'] != null)
        'genre': json['genre_name'],
    });
  }

  static HomeData fromJson(Map<String, dynamic> json) {
    return HomeData(
      hotForYou: parseHotForYou(json['hot_for_you']),
      trendingByGenre: parseTrendingByGenre(json['trending_by_genre']),
      moreOfWhatYouLike: (json['more_of_what_you_like']['tracks'] as List)
          .map((t) => parseTrack(t as Map<String, dynamic>))
          .toList(),
      mixedForYou: (json['mixed_for_you'] as List)
          .map((m) => parseMixedForYouItem(m as Map<String, dynamic>))
          .toList(),
      discoverWithStations: (json['discover_with_stations'] as List)
          .map((s) => parseDiscoverStation(s as Map<String, dynamic>))
          .toList(),
    );
  }

  static HotForYou parseHotForYou(Map<String, dynamic> json) {
    return HotForYou(
      track: parseTrack(json['track']),
      reason: json['reason'] as String? ?? '',
      validUntil: DateTime.parse(json['valid_until'] as String),
    );
  }

  static TrendingByGenreInitial parseTrendingByGenre(
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
      initialTab: parseGenreTabTracks(json['initial_tab']),
    );
  }

  static GenreTabTracks parseGenreTabTracks(Map<String, dynamic> json) {
    return GenreTabTracks(
      genreId: json['genre_id'] as String,
      genreName: json['genre_name'] as String,
      tracks: (json['tracks'] as List).map((t) => parseTrack(t)).toList(),
    );
  }

  static MixedForYouItem parseMixedForYouItem(Map<String, dynamic> json) {
    return MixedForYouItem(
      id: json['mix_id'] as String,
      label: json['title'] as String,
      flavor: '',
      genreName: '',
      coverImage: json['cover_url'] as String? ?? '',
      trackCount: 0,
      generatedAt: DateTime.now(),
      previewTrack: parseTrack(json['preview_track'] as Map<String, dynamic>),
    );
  }

  static DiscoverStation parseDiscoverStation(Map<String, dynamic> json) {
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
