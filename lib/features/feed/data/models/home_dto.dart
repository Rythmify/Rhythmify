import '../../../../core/data/models/track_dto.dart';
import '../../../../core/domain/entities/track.dart';
import '../../domain/entities/home_data.dart';
import '../../domain/entities/hot_for_you.dart';
import '../../domain/entities/trending_by_genre_initial.dart';
import '../../domain/entities/genre_tab.dart';
import '../../domain/entities/genre_tab_tracks.dart';
import '../../domain/entities/mixed_for_you_item.dart';
import '../../domain/entities/discover_station.dart';

/// A static DTO utility class responsible for parsing all home screen
/// JSON responses into typed domain entities.
///
/// All methods are static — [HomeDto] is never instantiated directly.
/// It acts as a centralized parsing layer between the raw API response
/// and the domain layer entities used by the home feature.
class HomeDto {
  /// Parses a single [Track] from a nullable JSON map.
  ///
  /// Returns an empty [TrackDto] if [json] is `null`. Normalizes
  /// missing `artist` and `genre` fields by falling back to
  /// `artist_name` and `genre_name` respectively before delegating
  /// to [TrackDto.fromJson].
  static Track parseTrack(Map<String, dynamic>? json) {
    if (json == null) {
      return TrackDto.fromJson({});
    }
    return TrackDto.fromJson({
      ...json,
      if (json['artist'] == null && json['artist_name'] != null)
        'artist': json['artist_name'],
      if (json['genre'] == null && json['genre_name'] != null)
        'genre': json['genre_name'],
    });
  }

  /// Parses the full home screen payload into a [HomeData] entity.
  ///
  /// Expects a `data` map from the `GET /home` response and delegates
  /// each section to its dedicated parse method. Null-safe defaults are
  /// applied for every section so that a missing key never causes a crash.
  static HomeData fromJson(Map<String, dynamic> json) {
    return HomeData(
      hotForYou: parseHotForYou(
        json['hot_for_you'] as Map<String, dynamic>? ?? {},
      ),

      trendingByGenre: parseTrendingByGenre(
        json['trending_by_genre'] as Map<String, dynamic>?,
      ),

      moreOfWhatYouLike:
          ((json['more_of_what_you_like'] as Map<String, dynamic>?)?['tracks']
                  as List?)
              ?.where((t) => t != null)
              .map((t) => parseTrack(t as Map<String, dynamic>?))
              .toList() ??
          [],

      mixedForYou: (json['mixed_for_you'] as List? ?? [])
          .where((m) => m != null)
          .map((m) => parseMixedForYouItem(m as Map<String, dynamic>))
          .toList(),

      discoverWithStations: (json['discover_with_stations'] as List? ?? [])
          .where((s) => s != null)
          .map((s) => parseDiscoverStation(s as Map<String, dynamic>))
          .toList(),
    );
  }

  /// Parses the "Hot For You" section from its JSON map into a [HotForYou] entity.
  ///
  /// Falls back to an empty string for [HotForYou.reason] and
  /// [DateTime.now] for [HotForYou.validUntil] if those fields are absent.
  static HotForYou parseHotForYou(Map<String, dynamic> json) {
    return HotForYou(
      track: parseTrack(json['track'] as Map<String, dynamic>?),
      reason: json['reason'] as String? ?? '',
      validUntil:
          DateTime.tryParse(json['valid_until'] as String? ?? '') ??
          DateTime.now(),
    );
  }

  /// Parses the "Trending By Genre" section into a [TrendingByGenreInitial] entity.
  ///
  /// Returns an empty [TrendingByGenreInitial] with no genres and an
  /// empty initial tab if [json] is `null`. Otherwise maps the `genres`
  /// array into [GenreTab] instances and parses the `initial_tab` via
  /// [parseGenreTabTracks].
  static TrendingByGenreInitial parseTrendingByGenre(
    Map<String, dynamic>? json,
  ) {
    if (json == null) {
      return TrendingByGenreInitial(
        genres: [],
        initialTab: GenreTabTracks(genreId: '', genreName: '', tracks: []),
      );
    }

    final genresJson = json['genres'] as List? ?? [];
    final initialTabJson = json['initial_tab'] as Map<String, dynamic>? ?? {};

    return TrendingByGenreInitial(
      genres: genresJson.where((g) => g != null).map((g) {
        final map = g as Map<String, dynamic>;
        return GenreTab(
          genreId: map['genre_id']?.toString() ?? '',
          genreName: map['genre_name']?.toString() ?? '',
        );
      }).toList(),

      initialTab: parseGenreTabTracks(initialTabJson),
    );
  }

  /// Parses a genre tab's track list into a [GenreTabTracks] entity.
  ///
  /// Returns an empty [GenreTabTracks] if [json] is `null`. Null entries
  /// in the `tracks` array are filtered out before parsing.
  static GenreTabTracks parseGenreTabTracks(Map<String, dynamic>? json) {
    if (json == null) {
      return GenreTabTracks(genreId: '', genreName: '', tracks: []);
    }

    return GenreTabTracks(
      genreId: json['genre_id']?.toString() ?? '',
      genreName: json['genre_name']?.toString() ?? '',
      tracks: (json['tracks'] as List? ?? [])
          .where((t) => t != null)
          .map((t) => parseTrack(t as Map<String, dynamic>?))
          .toList(),
    );
  }

  /// Parses a single "Mixed For You" item into a [MixedForYouItem] entity.
  ///
  /// Uses `mix_id` as the item identifier and `title` as the display label.
  /// Fields not yet provided by the backend (`flavor`, `genreName`,
  /// `trackCount`) are defaulted to empty/zero values.
  static MixedForYouItem parseMixedForYouItem(Map<String, dynamic> json) {
    return MixedForYouItem(
      id: json['mix_id']?.toString() ?? '',
      label: json['title']?.toString() ?? '',
      flavor: '',
      genreName: '',
      coverImage: json['cover_url'] as String? ?? '',
      trackCount: 0,
      generatedAt: DateTime.now(),
      previewTrack: parseTrack(json['preview_track'] as Map<String, dynamic>?),
    );
  }

  /// Parses a single discover station into a [DiscoverStation] entity.
  ///
  /// The `images` field is type-checked at runtime before casting, since
  /// the backend may return it in an inconsistent shape. Falls back to a
  /// default [StationImages] instance if the field is not a valid map.
  static DiscoverStation parseDiscoverStation(Map<String, dynamic> json) {
    final imagesJson = json['images']; // ← no cast yet

    return DiscoverStation(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      artistId: json['artist_id']?.toString() ?? '',
      artistName: json['artist_name'] as String? ?? '',
      coverImage: json['cover_image'] as String? ?? '',
      trackCount: json['track_count'] as int? ?? 0,
      followerCount: json['follower_count'] as int? ?? 0,
      images:
          imagesJson
              is Map<String, dynamic> // ← safe check
          ? StationImages(
              left: imagesJson['left'] as String?,
              center: imagesJson['center'] as String?,
              right: imagesJson['right'] as String?,
            )
          : const StationImages(),
    );
  }
}
