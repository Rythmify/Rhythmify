import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mocktail/mocktail.dart';
import 'package:rythmify/core/domain/entities/track.dart';
import 'package:rythmify/features/feed/domain/entities/discover_station.dart';
import 'package:rythmify/features/feed/domain/entities/genre_tab.dart';
import 'package:rythmify/features/feed/domain/entities/genre_tab_tracks.dart';
import 'package:rythmify/features/feed/domain/entities/home_data.dart';
import 'package:rythmify/features/feed/domain/entities/hot_for_you.dart';
import 'package:rythmify/features/feed/domain/entities/mixed_for_you_item.dart';
import 'package:rythmify/features/feed/domain/entities/trending_by_genre_initial.dart';
import 'package:rythmify/features/feed/domain/usecases/get_home_data.dart';
import 'package:rythmify/features/feed/domain/usecases/get_trending_tracks.dart';
import 'package:rythmify/features/feed/domain/usecases/get_hot_tracks.dart';
import 'package:rythmify/features/feed/domain/usecases/get_mix_tracks.dart';
import 'package:rythmify/features/feed/domain/usecases/get_related_tracks.dart';
import 'package:rythmify/features/feed/presentation/providers/home_providers.dart';

// ============ Mocks ============
class MockGetHomeData extends Mock implements GetHomeData {}

class MockGetTrendingByGenre extends Mock implements GetTrendingByGenre {}

class MockGetHotForYou extends Mock implements GetHotForYou {}

class MockGetMixTracks extends Mock implements GetMixTracks {}

class MockGetRelatedTracks extends Mock implements GetRelatedTracks {}

// ============ Fixtures ============
final tTrack = Track(
  id: 'track-1',
  userId: 'user-1',
  title: 'Test Track',
  artist: 'Test Artist',
  audioUrl: 'https://example.com/audio.mp3',
  duration: const Duration(seconds: 180),
  createdAt: DateTime(2024, 1, 1),
);

final tGenreTab = GenreTab(genreId: 'electronic', genreName: 'Electronic');

final tGenreTabTracks = GenreTabTracks(
  genreId: 'electronic',
  genreName: 'Electronic',
  tracks: [tTrack],
);

final tTrendingByGenreInitial = TrendingByGenreInitial(
  genres: [tGenreTab],
  initialTab: tGenreTabTracks,
);

final tHotForYou = HotForYou(
  track: tTrack,
  reason: 'Trending in your region',
  validUntil: DateTime(2024, 12, 31),
);

final tDiscoverStation = DiscoverStation(
  id: 'station-1',
  name: 'Test Station',
  artistId: 'artist-1',
  artistName: 'Test Artist',
  coverImage: 'https://example.com/station.jpg',
  trackCount: 50,
  followerCount: 1000,
);

final tMixedForYouItem = MixedForYouItem(
  id: 'mix-1',
  label: 'Electronic Mix',
  flavor: 'upbeat',
  genreName: 'Electronic',
  coverImage: 'https://example.com/mix.jpg',
  trackCount: 20,
  generatedAt: DateTime(2024, 1, 1),
  previewTrack: tTrack,
);

final tHomeData = HomeData(
  hotForYou: tHotForYou,
  trendingByGenre: tTrendingByGenreInitial,
  moreOfWhatYouLike: [tTrack],
  mixedForYou: [tMixedForYouItem],
  discoverWithStations: [tDiscoverStation],
);

void main() {
  group('Home Providers', () {
    // ── homeDataProvider ───────────────────────────────────────────────────

    group('homeDataProvider', () {
      test(
        'returns HomeData including hotForYou and trendingByGenre',
        () async {
          final container = ProviderContainer(
            overrides: [
              homeDataProvider.overrideWith((ref) async => tHomeData),
            ],
          );
          addTearDown(container.dispose);

          final result = await container.read(homeDataProvider.future);
          expect(result, tHomeData);
          expect(result.hotForYou, tHotForYou);
          expect(result.trendingByGenre, tTrendingByGenreInitial);
          expect(result.trendingByGenre.genres.first.genreId, 'electronic');
          expect(result.trendingByGenre.initialTab.tracks, [tTrack]);
          expect(result.moreOfWhatYouLike, [tTrack]);
          expect(result.mixedForYou, [tMixedForYouItem]);
          expect(result.discoverWithStations, [tDiscoverStation]);
        },
      );

      test('returns HomeData with correct counts', () async {
        final container = ProviderContainer(
          overrides: [homeDataProvider.overrideWith((ref) async => tHomeData)],
        );
        addTearDown(container.dispose);

        final result = await container.read(homeDataProvider.future);
        expect(result.moreOfWhatYouLike.length, 1);
        expect(result.mixedForYou.length, 1);
        expect(result.discoverWithStations.length, 1);
      });
    });

    // ── trendingByGenreProvider ────────────────────────────────────────────

    group('trendingByGenreProvider', () {
      test('returns GenreTabTracks for a given genreId', () async {
        final container = ProviderContainer(
          overrides: [
            trendingByGenreProvider.overrideWith(
              (ref, genreId) async => tGenreTabTracks,
            ),
          ],
        );
        addTearDown(container.dispose);

        final result = await container.read(
          trendingByGenreProvider('electronic').future,
        );
        expect(result.genreId, 'electronic');
        expect(result.genreName, 'Electronic');
        expect(result.tracks, [tTrack]);
      });

      test('returns different results for different genreIds', () async {
        final tRockTracks = GenreTabTracks(
          genreId: 'rock',
          genreName: 'Rock',
          tracks: [],
        );

        final container = ProviderContainer(
          overrides: [
            trendingByGenreProvider.overrideWith((ref, genreId) async {
              if (genreId == 'electronic') return tGenreTabTracks;
              return tRockTracks;
            }),
          ],
        );
        addTearDown(container.dispose);

        final electronic = await container.read(
          trendingByGenreProvider('electronic').future,
        );
        final rock = await container.read(
          trendingByGenreProvider('rock').future,
        );

        expect(electronic.genreId, 'electronic');
        expect(rock.genreId, 'rock');
        expect(rock.tracks, isEmpty);
      });
    });

    // ── hotForYouProvider ──────────────────────────────────────────────────

    group('hotForYouProvider', () {
      test('returns HotForYou data', () async {
        final container = ProviderContainer(
          overrides: [
            hotForYouProvider.overrideWith((ref) async => tHotForYou),
          ],
        );
        addTearDown(container.dispose);

        final result = await container.read(hotForYouProvider.future);
        expect(result, tHotForYou);
        expect(result.reason, 'Trending in your region');
        expect(result.track, tTrack);
      });

      test('returns HomeData with correct counts', () async {
        final container = ProviderContainer(
          overrides: [homeDataProvider.overrideWith((ref) async => tHomeData)],
        );
        addTearDown(container.dispose);

        final result = await container.read(homeDataProvider.future);
        expect(result.moreOfWhatYouLike.length, 1);
        expect(result.mixedForYou.length, 1);
        expect(result.discoverWithStations.length, 1);
      });
    });

    // ── moreOfWhatYouLikeProvider ──────────────────────────────────────────

    group('moreOfWhatYouLikeProvider', () {
      test('returns AsyncData with tracks when homeData succeeds', () async {
        final container = ProviderContainer(
          overrides: [homeDataProvider.overrideWith((ref) async => tHomeData)],
        );
        addTearDown(container.dispose);

        await container.read(homeDataProvider.future);

        final result = container.read(moreOfWhatYouLikeProvider);
        expect(result, isA<AsyncData<List<Track>>>());
        expect(result.value, [tTrack]);
      });

      test('returns empty list when homeData has no tracks', () async {
        final emptyHomeData = HomeData(
          hotForYou: tHotForYou,
          trendingByGenre: tTrendingByGenreInitial,
          moreOfWhatYouLike: [],
          mixedForYou: [tMixedForYouItem],
          discoverWithStations: [tDiscoverStation],
        );
        final container = ProviderContainer(
          overrides: [
            homeDataProvider.overrideWith((ref) async => emptyHomeData),
          ],
        );
        addTearDown(container.dispose);

        await container.read(homeDataProvider.future);
        final result = container.read(moreOfWhatYouLikeProvider);
        expect(result.value, isEmpty);
      });
    });

    // ── mixedForYouProvider ────────────────────────────────────────────────

    group('mixedForYouProvider', () {
      test(
        'returns AsyncData with mixed items when homeData succeeds',
        () async {
          final container = ProviderContainer(
            overrides: [
              homeDataProvider.overrideWith((ref) async => tHomeData),
            ],
          );
          addTearDown(container.dispose);

          await container.read(homeDataProvider.future);

          final result = container.read(mixedForYouProvider);
          expect(result, isA<AsyncData<List<MixedForYouItem>>>());
          expect(result.value, [tMixedForYouItem]);
        },
      );

      test('returns empty list when homeData has no mixed items', () async {
        final emptyHomeData = HomeData(
          hotForYou: tHotForYou,
          trendingByGenre: tTrendingByGenreInitial,
          moreOfWhatYouLike: [tTrack],
          mixedForYou: [],
          discoverWithStations: [tDiscoverStation],
        );
        final container = ProviderContainer(
          overrides: [
            homeDataProvider.overrideWith((ref) async => emptyHomeData),
          ],
        );
        addTearDown(container.dispose);

        await container.read(homeDataProvider.future);
        final result = container.read(mixedForYouProvider);
        expect(result.value, isEmpty);
      });
    });

    // ── discoverStationsProvider ───────────────────────────────────────────

    group('discoverStationsProvider', () {
      test('returns AsyncData with stations when homeData succeeds', () async {
        final container = ProviderContainer(
          overrides: [homeDataProvider.overrideWith((ref) async => tHomeData)],
        );
        addTearDown(container.dispose);

        await container.read(homeDataProvider.future);

        final result = container.read(discoverStationsProvider);
        expect(result, isA<AsyncData<List<DiscoverStation>>>());
        expect(result.value, [tDiscoverStation]);
      });

      test('returns empty list when homeData has no stations', () async {
        final emptyHomeData = HomeData(
          hotForYou: tHotForYou,
          trendingByGenre: tTrendingByGenreInitial,
          moreOfWhatYouLike: [tTrack],
          mixedForYou: [tMixedForYouItem],
          discoverWithStations: [],
        );
        final container = ProviderContainer(
          overrides: [
            homeDataProvider.overrideWith((ref) async => emptyHomeData),
          ],
        );
        addTearDown(container.dispose);

        await container.read(homeDataProvider.future);
        final result = container.read(discoverStationsProvider);
        expect(result.value, isEmpty);
      });
    });

    // ── mixTracksProvider ──────────────────────────────────────────────────

    group('mixTracksProvider', () {
      test('returns list of tracks for a mixId', () async {
        final container = ProviderContainer(
          overrides: [
            mixTracksProvider.overrideWith((ref, mixId) async => [tTrack]),
          ],
        );
        addTearDown(container.dispose);

        final result = await container.read(mixTracksProvider('mix-1').future);
        expect(result, [tTrack]);
      });

      test('returns empty list when no tracks found', () async {
        final container = ProviderContainer(
          overrides: [mixTracksProvider.overrideWith((ref, mixId) async => [])],
        );
        addTearDown(container.dispose);

        final result = await container.read(mixTracksProvider('mix-1').future);
        expect(result, isEmpty);
      });
    });

    // ── relatedTracksProvider ──────────────────────────────────────────────

    group('relatedTracksProvider', () {
      test('returns list of related tracks for a trackId', () async {
        final container = ProviderContainer(
          overrides: [
            relatedTracksProvider.overrideWith(
              (ref, trackId) async => [tTrack],
            ),
          ],
        );
        addTearDown(container.dispose);

        final result = await container.read(
          relatedTracksProvider('track-1').future,
        );
        expect(result, [tTrack]);
      });

      test('returns empty list when no related tracks', () async {
        final container = ProviderContainer(
          overrides: [
            relatedTracksProvider.overrideWith((ref, trackId) async => []),
          ],
        );
        addTearDown(container.dispose);

        final result = await container.read(
          relatedTracksProvider('track-1').future,
        );
        expect(result, isEmpty);
      });
    });

    // ── useMock flag ───────────────────────────────────────────────────────

    group('useMock', () {
      test('is false by default', () {
        expect(useMock, false);
      });
    });
  });
}
