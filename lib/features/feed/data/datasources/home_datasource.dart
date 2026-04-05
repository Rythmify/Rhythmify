import '../../../../core/domain/entities/track.dart';
import '../../domain/entities/home_data.dart';
import '../../domain/entities/genre_tab_tracks.dart';
import '../../domain/entities/hot_for_you.dart';
import '../../domain/entities/trending_by_genre_initial.dart';
import '../../domain/entities/genre_tab.dart';
import '../../domain/entities/mixed_for_you_item.dart';
import '../../domain/entities/discover_station.dart';

class HomeDatasource {
  // Shared mock track to avoid repetition
  Track get _mockTrack => Track(
    id: 'e5f6a7b8-c9d0-1234-efab-567890abcdef',
    userId: 'a1b2c3d4-e5f6-7890-abcd-ef1234567890',
    title: 'Summer Vibes',
    artist: 'DJ Karim',
    audioUrl: 'assets/audio/Track_audio_1.mp3',
    streamUrl: 'https://cdn.rythmify.com/tracks/e5f6a7b8/stream.mp3',
    coverImage: 'assets/images/track_6.jpg',
    duration: const Duration(seconds: 213),
    playCount: 4200,
    likeCount: 312,
    repostCount: 47,
    createdAt: DateTime(2026, 3, 1),
    genre: 'Electronic',
  );

  Future<HomeData> getHomeData() async {
    return HomeData(
      hotForYou: HotForYou(
        track: _mockTrack,
        reason: 'Based on your recent listens',
        validUntil: DateTime(2026, 4, 5, 20, 22),
      ),
      trendingByGenre: TrendingByGenreInitial(
        genres: const [
          GenreTab(genreId: 'genre-1', genreName: 'Electronic'),
          GenreTab(genreId: 'genre-2', genreName: 'Hip-Hop'),
          GenreTab(genreId: 'genre-3', genreName: 'Pop'),
          GenreTab(genreId: 'genre-3', genreName: 'Indie'),
          GenreTab(genreId: 'genre-3', genreName: 'Country'),
          GenreTab(genreId: 'genre-3', genreName: 'Classic'),
        ],
        initialTab: GenreTabTracks(
          genreId: 'genre-1',
          genreName: 'Electronic',
          tracks: List.generate(6, (_) => _mockTrack),
        ),
      ),
      moreOfWhatYouLike: List.generate(6, (_) => _mockTrack),
      mixedForYou: List.generate(
        6,
        (i) => MixedForYouItem(
          id: 'mix-$i',
          label: 'MIX ${i + 1}',
          flavor: 'listening_history',
          genreName: 'Electronic',
          coverImage: 'assets/images/track_6.jpg',
          trackCount: 20,
          generatedAt: DateTime(2026, 4, 5),
          previewTrack: _mockTrack,
        ),
      ),

      discoverWithStations: List.generate(
        6,
        (i) => DiscoverStation(
          id: 'station-$i',
          name: 'Based on Artist ${i + 1}',
          artistId: 'artist-$i',
          artistName: 'Artist ${i + 1}',
          coverImage: 'assets/images/track_6.jpg',
          trackCount: 50,
          followerCount: 3200 + i * 200,
        ),
      ),
    );
  }

  Future<GenreTabTracks> getTrendingByGenre(String genreId) async {
    return GenreTabTracks(
      genreId: genreId,
      genreName: 'Electronic',
      tracks: List.generate(6, (_) => _mockTrack),
    );
  }

  Future<HotForYou> getHotForYou() async {
    return HotForYou(
      track: _mockTrack,
      reason: 'Based on your recent listens',
      validUntil: DateTime(2026, 4, 5, 20, 22),
    );
  }

  Future<List<Track>> getMoreOfWhatYouLike() async {
    return List.generate(6, (_) => _mockTrack);
  }

  Future<List<MixedForYouItem>> getMixedForYou() async {
    return List.generate(
      6,
      (i) => MixedForYouItem(
        id: 'mix-$i',
        label: 'MIX ${i + 1}',
        flavor: 'listening_history',
        genreName: 'Electronic',
        coverImage: 'assets/images/track_6.jpg',
        trackCount: 20,
        generatedAt: DateTime(2026, 4, 5),
        previewTrack: _mockTrack,
      ),
    );
  }

  Future<List<DiscoverStation>> getDiscoverStations() async {
    return List.generate(
      6,
      (i) => DiscoverStation(
        id: 'station-$i',
        name: 'Based on Artist ${i + 1}',
        artistId: 'artist-$i',
        artistName: 'Artist ${i + 1}',
        coverImage: 'assets/images/track_6.jpg',
        trackCount: 50,
        followerCount: 3200 + i * 200,
      ),
    );
  }
}
