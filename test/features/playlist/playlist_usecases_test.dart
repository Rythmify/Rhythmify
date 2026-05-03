import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:rythmify/core/error/failures.dart';
import 'package:rythmify/features/playlist/domain/entities/collection_type.dart';
import 'package:rythmify/features/playlist/domain/entities/playlist_entity.dart';
import 'package:rythmify/features/playlist/domain/entities/playlist_track.dart';
import 'package:rythmify/features/playlist/domain/entities/station_entity.dart';
import 'package:rythmify/features/playlist/domain/repositories/playlist_repository.dart';
import 'package:rythmify/features/playlist/domain/usecases/playlist_usecases.dart';

class MockPlaylistRepository extends Mock implements PlaylistRepository {}

class FakeFile extends Fake implements File {}

const _failure = PlaylistServerFailure();

final _playlist = PlaylistEntity(
  id: 'playlist-1',
  name: 'Night Drive',
  ownerName: 'Owner',
  ownerId: 'user-1',
  isPublic: true,
  type: PlaylistType.playlist,
  trackCount: 1,
  totalDuration: const Duration(minutes: 3),
  createdAt: DateTime(2024, 1, 1),
);

final _track = PlaylistTrack(
  id: 'track-1',
  title: 'Track',
  artistName: 'Artist',
  duration: const Duration(minutes: 3),
  playCount: 10,
  position: 1,
);

final _station = StationEntity(
  id: 'artist-1',
  name: 'Artist Radio',
  seedArtistId: 'artist-1',
  seedArtistDisplayName: 'Artist',
  trackCount: 25,
);

void main() {
  late MockPlaylistRepository repository;

  setUpAll(() {
    registerFallbackValue(FakeFile());
    registerFallbackValue(CollectionType.playlist);
  });

  setUp(() {
    repository = MockPlaylistRepository();
  });

  group('Playlist use cases', () {
    test('fetchMyPlaylists forwards pagination/filter arguments', () async {
      when(
        () => repository.fetchMyPlaylists(
          filter: any(named: 'filter'),
          albumView: any(named: 'albumView'),
          limit: any(named: 'limit'),
          offset: any(named: 'offset'),
        ),
      ).thenAnswer((_) async => Right([_playlist]));

      final result = await FetchMyPlaylistsUseCase(repository)(
        filter: 'liked',
        albumView: true,
        limit: 10,
        offset: 20,
      );

      expect(result.isRight(), isTrue);
      expect(result.getOrElse(() => []), [_playlist]);
      verify(
        () => repository.fetchMyPlaylists(
          filter: 'liked',
          albumView: true,
          limit: 10,
          offset: 20,
        ),
      ).called(1);
    });

    test(
      'fetch detail and tracks pass secret tokens through repository',
      () async {
        when(
          () => repository.fetchPlaylistDetail(
            playlistId: any(named: 'playlistId'),
            secretToken: any(named: 'secretToken'),
          ),
        ).thenAnswer((_) async => Right(_playlist));
        when(
          () => repository.fetchPlaylistTracks(
            playlistId: any(named: 'playlistId'),
            secretToken: any(named: 'secretToken'),
            page: any(named: 'page'),
            limit: any(named: 'limit'),
          ),
        ).thenAnswer((_) async => Right([_track]));

        await FetchPlaylistDetailUseCase(repository)(
          playlistId: 'private-1',
          secretToken: 'secret-token',
        );
        await FetchPlaylistTracksUseCase(repository)(
          playlistId: 'private-1',
          secretToken: 'secret-token',
          page: 2,
          limit: 5,
        );

        verify(
          () => repository.fetchPlaylistDetail(
            playlistId: 'private-1',
            secretToken: 'secret-token',
          ),
        ).called(1);
        verify(
          () => repository.fetchPlaylistTracks(
            playlistId: 'private-1',
            secretToken: 'secret-token',
            page: 2,
            limit: 5,
          ),
        ).called(1);
      },
    );

    test(
      'update trims valid names and rejects empty names before repository',
      () async {
        when(
          () => repository.updatePlaylist(
            playlistId: any(named: 'playlistId'),
            name: any(named: 'name'),
            description: any(named: 'description'),
            isPublic: any(named: 'isPublic'),
            coverImage: any(named: 'coverImage'),
            removeCover: any(named: 'removeCover'),
            subtype: any(named: 'subtype'),
            releaseDate: any(named: 'releaseDate'),
            genreId: any(named: 'genreId'),
            tags: any(named: 'tags'),
          ),
        ).thenAnswer((_) async => Right(_playlist.copyWith(name: 'New Name')));

        final ok = await UpdatePlaylistUseCase(repository)(
          playlistId: 'playlist-1',
          name: '  New Name  ',
          description: 'desc',
          isPublic: false,
        );
        final invalid = await UpdatePlaylistUseCase(repository)(
          playlistId: 'playlist-1',
          name: '   ',
        );

        expect(ok.isRight(), isTrue);
        expect(
          invalid.fold((l) => l, (_) => null),
          isA<PlaylistValidationFailure>(),
        );
        verify(
          () => repository.updatePlaylist(
            playlistId: 'playlist-1',
            name: 'New Name',
            description: 'desc',
            isPublic: false,
            coverImage: null,
            removeCover: false,
            subtype: null,
            releaseDate: null,
            genreId: null,
            tags: null,
          ),
        ).called(1);
      },
    );

    test('delete/add/remove/reorder delegate and preserve failures', () async {
      when(
        () => repository.deletePlaylist('playlist-1'),
      ).thenAnswer((_) async => const Right(null));
      when(
        () => repository.addTrackToPlaylist(
          playlistId: any(named: 'playlistId'),
          trackId: any(named: 'trackId'),
          position: any(named: 'position'),
        ),
      ).thenAnswer((_) async => const Right(null));
      when(
        () => repository.removeTrackFromPlaylist(
          playlistId: any(named: 'playlistId'),
          trackId: any(named: 'trackId'),
        ),
      ).thenAnswer((_) async => const Left(_failure));
      when(
        () => repository.reorderPlaylistTracks(
          playlistId: any(named: 'playlistId'),
          orderedTrackIds: any(named: 'orderedTrackIds'),
        ),
      ).thenAnswer((_) async => const Right(null));

      expect(
        (await DeletePlaylistUseCase(repository)('playlist-1')).isRight(),
        isTrue,
      );
      expect(
        (await AddTrackToPlaylistUseCase(repository)(
          playlistId: 'playlist-1',
          trackId: 'track-1',
          position: 2,
        )).isRight(),
        isTrue,
      );
      expect(
        await RemoveTrackFromPlaylistUseCase(repository)(
          playlistId: 'playlist-1',
          trackId: 'track-1',
        ),
        const Left(_failure),
      );
      expect(
        (await ReorderPlaylistTracksUseCase(repository)(
          playlistId: 'playlist-1',
          orderedTrackIds: ['track-2', 'track-1'],
        )).isRight(),
        isTrue,
      );

      verify(() => repository.deletePlaylist('playlist-1')).called(1);
      verify(
        () => repository.addTrackToPlaylist(
          playlistId: 'playlist-1',
          trackId: 'track-1',
          position: 2,
        ),
      ).called(1);
    });

    test('reorder rejects an empty order before calling repository', () async {
      final result = await ReorderPlaylistTracksUseCase(repository)(
        playlistId: 'playlist-1',
        orderedTrackIds: const [],
      );

      expect(
        result.fold((l) => l, (_) => null),
        isA<PlaylistValidationFailure>(),
      );
      verifyNever(
        () => repository.reorderPlaylistTracks(
          playlistId: any(named: 'playlistId'),
          orderedTrackIds: any(named: 'orderedTrackIds'),
        ),
      );
    });

    test(
      'toggle like/repost choose inverse action from current UI state',
      () async {
        when(
          () => repository.likePlaylist('playlist-1'),
        ).thenAnswer((_) async => const Right(null));
        when(
          () => repository.unlikePlaylist('playlist-1'),
        ).thenAnswer((_) async => const Right(null));
        when(
          () => repository.repostPlaylist('playlist-1'),
        ).thenAnswer((_) async => const Right(null));
        when(
          () => repository.removePlaylistRepost('playlist-1'),
        ).thenAnswer((_) async => const Right(null));

        await TogglePlaylistLikeUseCase(repository)(
          playlistId: 'playlist-1',
          liked: false,
        );
        await TogglePlaylistLikeUseCase(repository)(
          playlistId: 'playlist-1',
          liked: true,
        );
        await TogglePlaylistRepostUseCase(repository)(
          playlistId: 'playlist-1',
          reposted: false,
        );
        await TogglePlaylistRepostUseCase(repository)(
          playlistId: 'playlist-1',
          reposted: true,
        );

        verify(() => repository.likePlaylist('playlist-1')).called(1);
        verify(() => repository.unlikePlaylist('playlist-1')).called(1);
        verify(() => repository.repostPlaylist('playlist-1')).called(1);
        verify(() => repository.removePlaylistRepost('playlist-1')).called(1);
      },
    );

    test('station use cases forward pagination and results', () async {
      when(
        () => repository.fetchStations(
          limit: any(named: 'limit'),
          offset: any(named: 'offset'),
        ),
      ).thenAnswer((_) async => Right([_station]));
      when(
        () => repository.fetchStationTracks(
          artistId: any(named: 'artistId'),
          limit: any(named: 'limit'),
          offset: any(named: 'offset'),
        ),
      ).thenAnswer((_) async => Right([_track]));

      final stations = await FetchStationsUseCase(repository)(
        limit: 4,
        offset: 8,
      );
      final stationTracks = await FetchStationTracksUseCase(repository)(
        artistId: 'artist-1',
        limit: 9,
        offset: 3,
      );

      expect(stations.isRight(), isTrue);
      expect(stations.getOrElse(() => []), [_station]);
      expect(stationTracks.isRight(), isTrue);
      expect(stationTracks.getOrElse(() => []), [_track]);
    });
  });
}
