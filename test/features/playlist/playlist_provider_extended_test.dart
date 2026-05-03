import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:rythmify/core/domain/entities/track.dart';
import 'package:rythmify/features/authentication/domain/entities/user_entity.dart';
import 'package:rythmify/features/authentication/presentation/providers/auth_provider.dart';
import 'package:rythmify/features/authentication/presentation/providers/auth_state.dart';
import 'package:rythmify/features/playlist/data/datasources/playlist_remote_datasource.dart';
import 'package:rythmify/features/playlist/data/mock/playlist_mock_data.dart';
import 'package:rythmify/features/playlist/domain/entities/playlist_entity.dart';
import 'package:rythmify/features/playlist/domain/entities/playlist_track.dart';
import 'package:rythmify/features/playlist/presentation/providers/playlist_provider.dart';

class MockPlaylistRemoteDatasource extends Mock
    implements PlaylistRemoteDatasource {}

class TestAuthNotifier extends AuthNotifier {
  TestAuthNotifier([this.initial = const AuthUnauthenticated()]);

  final AuthState initial;

  @override
  AuthState build() => initial;
}

DioException _dioError(String path, [int statusCode = 500]) {
  return DioException(
    requestOptions: RequestOptions(path: path),
    response: Response(
      requestOptions: RequestOptions(path: path),
      statusCode: statusCode,
    ),
  );
}

final _playlist = PlaylistEntity(
  id: 'playlist-1',
  name: 'Night Drive',
  ownerName: 'Owner',
  ownerId: 'owner-1',
  isPublic: true,
  type: PlaylistType.playlist,
  trackCount: 2,
  totalDuration: const Duration(minutes: 7),
  createdAt: DateTime(2024, 1, 1),
);

final _album = _playlist.copyWith(
  id: 'album-1',
  name: 'Album',
  type: PlaylistType.album,
);

final _station = _playlist.copyWith(
  id: 'station-1',
  name: 'Artist Radio',
  type: PlaylistType.station,
  seedArtistName: 'artist-1',
);

final _trackRadio = _playlist.copyWith(
  id: 'radio-1',
  name: 'More like Track',
  isTrackRadio: true,
);

final _mix = _playlist.copyWith(
  id: 'mix-1',
  name: 'Daily Mix',
  isGeneratedMix: true,
);

final _tracks = [
  PlaylistTrack(
    id: 'track-1',
    title: 'One',
    artistName: 'Artist',
    duration: const Duration(minutes: 3),
    playCount: 10,
    position: 1,
    coverUrl: 'cover.jpg',
  ),
  PlaylistTrack(
    id: 'track-2',
    title: 'Two',
    artistName: 'Artist',
    duration: const Duration(minutes: 4),
    playCount: 20,
    position: 2,
  ),
];

PlaylistTrack _suggestionTrack() => const PlaylistTrack(
  id: 'suggestion-1',
  title: 'Two',
  artistName: 'Artist',
  duration: Duration(minutes: 4),
  playCount: 20,
  position: 0,
);

ProviderContainer _container(
  MockPlaylistRemoteDatasource datasource, {
  AuthState authState = const AuthUnauthenticated(),
}) {
  final container = ProviderContainer(
    overrides: [
      playlistDatasourceProvider.overrideWithValue(datasource),
      authProvider.overrideWith(() => TestAuthNotifier(authState)),
    ],
  );
  addTearDown(container.dispose);
  return container;
}

void main() {
  late MockPlaylistRemoteDatasource datasource;

  setUp(() {
    datasource = MockPlaylistRemoteDatasource();
    PlaylistMockData.instance.syncFromBackend([]);
  });

  group('PlaylistListNotifier additional behavior', () {
    test(
      'loadLikedAlbums uses liked filter and reports API failures',
      () async {
        when(
          () => datasource.fetchMyPlaylists(filter: 'liked'),
        ).thenAnswer((_) async => [_album]);

        final container = _container(datasource);
        await container.read(playlistListProvider.notifier).loadLikedAlbums();

        expect(
          container.read(playlistListProvider).playlists.single.id,
          'album-1',
        );

        when(
          () => datasource.fetchMyPlaylists(filter: 'liked'),
        ).thenThrow(_dioError('/playlists', 403));
        await container.read(playlistListProvider.notifier).loadLikedAlbums();

        final failed = container.read(playlistListProvider);
        expect(failed.playlists, isEmpty);
        expect(failed.error, 'Could not load liked albums');
      },
    );

    test(
      'updateCoverImage updates cached state without making a network call',
      () {
        PlaylistMockData.instance.syncFromBackend([_playlist]);

        final container = _container(datasource);
        container
            .read(playlistListProvider.notifier)
            .updateCoverImage(playlistId: 'playlist-1', localPath: 'local.jpg');

        final state = container.read(playlistListProvider);
        expect(state.playlists.single.coverUrl, 'local.jpg');
        verifyNever(
          () => datasource.updatePlaylist(
            playlistId: any(named: 'playlistId'),
            name: any(named: 'name'),
            isPublic: any(named: 'isPublic'),
          ),
        );
      },
    );

    test(
      'copyPlaylist copies regular playlists and skips tracks rejected by the API',
      () async {
        final created = _playlist.copyWith(id: 'copy-1', name: 'Copy');
        when(
          () => datasource.createPlaylist(name: 'Copy', isPublic: false),
        ).thenAnswer((_) async => created);
        when(
          () => datasource.fetchPlaylistTracks('playlist-1'),
        ).thenAnswer((_) async => _tracks);
        when(
          () => datasource.addTrackToPlaylist(
            playlistId: 'copy-1',
            trackId: 'track-1',
          ),
        ).thenAnswer((_) async {});
        when(
          () => datasource.addTrackToPlaylist(
            playlistId: 'copy-1',
            trackId: 'track-2',
          ),
        ).thenThrow(_dioError('/playlists/copy-1/tracks', 409));
        when(
          () => datasource.fetchMyPlaylists(filter: 'created'),
        ).thenAnswer((_) async => [created]);

        final container = _container(datasource);
        final id = await container
            .read(playlistListProvider.notifier)
            .copyPlaylist(
              'playlist-1',
              overrideName: 'Copy',
              overridePublic: false,
              sourceEntity: _playlist,
            );

        expect(id, 'copy-1');
        verify(() => datasource.fetchPlaylistTracks('playlist-1')).called(1);
        verify(
          () => datasource.addTrackToPlaylist(
            playlistId: 'copy-1',
            trackId: 'track-1',
          ),
        ).called(1);
        verify(
          () => datasource.addTrackToPlaylist(
            playlistId: 'copy-1',
            trackId: 'track-2',
          ),
        ).called(1);
      },
    );

    test(
      'copyPlaylist uses station, radio, and mix-specific track sources',
      () async {
        final created = _playlist.copyWith(
          id: 'copy-2',
          name: 'Copy of Source',
        );
        when(
          () => datasource.createPlaylist(
            name: any(named: 'name'),
            isPublic: any(named: 'isPublic'),
          ),
        ).thenAnswer((_) async => created);
        when(
          () => datasource.addTrackToPlaylist(
            playlistId: any(named: 'playlistId'),
            trackId: any(named: 'trackId'),
          ),
        ).thenAnswer((_) async {});
        when(
          () => datasource.fetchMyPlaylists(filter: 'created'),
        ).thenAnswer((_) async => [created]);
        when(
          () => datasource.fetchStationTracks('artist-1', limit: 50),
        ).thenAnswer((_) async => [_tracks.first]);
        when(
          () => datasource.fetchRadioTracks('radio-1'),
        ).thenAnswer((_) async => []);
        when(
          () => datasource.fetchPlaylistTracks('radio-1'),
        ).thenAnswer((_) async => [_tracks.first]);
        when(
          () => datasource.fetchMixTracks('mix-1'),
        ).thenAnswer((_) async => []);
        when(
          () => datasource.fetchPlaylistTracks('mix-1'),
        ).thenAnswer((_) async => [_tracks.last]);

        final container = _container(datasource);
        final notifier = container.read(playlistListProvider.notifier);

        expect(
          await notifier.copyPlaylist('station-1', sourceEntity: _station),
          'copy-2',
        );
        expect(
          await notifier.copyPlaylist('radio-1', sourceEntity: _trackRadio),
          'copy-2',
        );
        expect(
          await notifier.copyPlaylist('mix-1', sourceEntity: _mix),
          'copy-2',
        );

        verify(
          () => datasource.fetchStationTracks('artist-1', limit: 50),
        ).called(1);
        verify(() => datasource.fetchRadioTracks('radio-1')).called(1);
        verify(() => datasource.fetchPlaylistTracks('radio-1')).called(1);
        verify(() => datasource.fetchMixTracks('mix-1')).called(1);
        verify(() => datasource.fetchPlaylistTracks('mix-1')).called(1);
      },
    );

    test('copyPlaylist returns null when playlist creation fails', () async {
      when(
        () => datasource.createPlaylist(
          name: any(named: 'name'),
          isPublic: any(named: 'isPublic'),
        ),
      ).thenThrow(_dioError('/playlists', 422));

      final container = _container(datasource);
      final id = await container
          .read(playlistListProvider.notifier)
          .copyPlaylist('playlist-1', sourceEntity: _playlist);

      expect(id, isNull);
    });

    test(
      'conversion methods call datasource/cache paths and tolerate failures',
      () async {
        PlaylistMockData.instance.syncFromBackend([_playlist]);
        PlaylistMockData.instance.addTrack(
          playlistId: 'playlist-1',
          track: _tracks.first,
        );
        when(
          () => datasource.updatePlaylist(
            playlistId: 'playlist-1',
            subtype: 'album',
            releaseDate: any(named: 'releaseDate'),
          ),
        ).thenAnswer((_) async => _album);
        when(
          () => datasource.updatePlaylist(
            playlistId: 'playlist-1',
            subtype: 'playlist',
          ),
        ).thenAnswer((_) async => _playlist);
        when(
          () => datasource.fetchRelatedTracks('track-1', limit: 50),
        ).thenAnswer((_) async => [_tracks.last]);
        when(
          () => datasource.fetchMyPlaylists(filter: 'created'),
        ).thenAnswer((_) async => [_playlist]);

        final container = _container(datasource);
        final notifier = container.read(playlistListProvider.notifier);

        await notifier.convertToAlbum('playlist-1');
        await notifier.convertToPlaylist('playlist-1');
        await notifier.convertToStation('playlist-1');

        verify(
          () => datasource.updatePlaylist(
            playlistId: 'playlist-1',
            subtype: 'album',
            releaseDate: any(named: 'releaseDate'),
          ),
        ).called(1);
        verify(
          () => datasource.updatePlaylist(
            playlistId: 'playlist-1',
            subtype: 'playlist',
          ),
        ).called(1);
        verify(
          () => datasource.fetchRelatedTracks('track-1', limit: 50),
        ).called(1);

        when(
          () => datasource.updatePlaylist(
            playlistId: 'broken',
            subtype: 'playlist',
          ),
        ).thenThrow(_dioError('/playlists/broken'));
        await notifier.convertToPlaylist('broken');
      },
    );

    test(
      'createStation variants add local station playlists from playlist and core track entities',
      () {
        final container = _container(datasource);
        final notifier = container.read(playlistListProvider.notifier);

        final fromPlaylistTrack = notifier.createStation(_tracks.first);
        final fromCoreTrack = notifier.createStationFromTrack(
          Track(
            id: 'core-track-1',
            userId: 'artist-1',
            title: 'Core Track',
            artist: 'Core Artist',
            audioUrl: 'audio.mp3',
            duration: const Duration(minutes: 2),
            createdAt: DateTime(2024, 1, 1),
            coverImage: 'core.jpg',
          ),
        );

        expect(fromPlaylistTrack.type, PlaylistType.station);
        expect(fromPlaylistTrack.seedArtistName, 'Artist');
        expect(fromCoreTrack.name, 'Core Artist Radio');
        expect(container.read(playlistListProvider).playlists, hasLength(2));
      },
    );
  });

  group('PlaylistDetailNotifier generated-content behavior', () {
    test('passes authenticated user identity to detail fetch', () async {
      when(
        () => datasource.fetchPlaylistDetail(
          'playlist-1',
          currentUserId: any(named: 'currentUserId'),
          currentUserName: any(named: 'currentUserName'),
        ),
      ).thenAnswer((_) async => _playlist);
      when(
        () => datasource.fetchPlaylistTracks('playlist-1'),
      ).thenAnswer((_) async => _tracks);

      final container = _container(
        datasource,
        authState: const AuthAuthenticated(
          UserEntity(
            id: 'current-user',
            email: 'me@example.com',
            displayName: 'Current User',
            isEmailVerified: true,
          ),
        ),
      );
      await container.read(playlistDetailProvider.notifier).init('playlist-1');

      verify(
        () => datasource.fetchPlaylistDetail(
          'playlist-1',
          currentUserId: 'current-user',
          currentUserName: 'Current User',
        ),
      ).called(1);
    });

    test(
      'init fetches station tracks using seed artist and falls back to playlist tracks without seed',
      () async {
        when(
          () => datasource.fetchPlaylistDetail(
            'station-1',
            currentUserId: any(named: 'currentUserId'),
            currentUserName: any(named: 'currentUserName'),
          ),
        ).thenAnswer((_) async => _station);
        when(
          () => datasource.fetchStationTracks('artist-1', limit: 50),
        ).thenAnswer((_) async => [_tracks.first]);
        final noSeed = PlaylistEntity(
          id: 'station-2',
          name: 'Seedless Station',
          ownerName: 'Owner',
          ownerId: 'owner-1',
          isPublic: true,
          type: PlaylistType.station,
          trackCount: 1,
          totalDuration: const Duration(minutes: 4),
          createdAt: DateTime(2024, 1, 1),
        );
        when(
          () => datasource.fetchPlaylistDetail(
            'station-2',
            currentUserId: any(named: 'currentUserId'),
            currentUserName: any(named: 'currentUserName'),
          ),
        ).thenAnswer((_) async => noSeed);
        when(
          () => datasource.fetchPlaylistTracks('station-2'),
        ).thenAnswer((_) async => [_tracks.last]);

        final container = _container(datasource);
        await container.read(playlistDetailProvider.notifier).init('station-1');
        expect(
          container.read(playlistDetailProvider).tracks.single.id,
          'track-1',
        );

        await container.read(playlistDetailProvider.notifier).init('station-2');
        expect(
          container.read(playlistDetailProvider).tracks.single.id,
          'track-2',
        );
      },
    );

    test(
      'init falls back from empty radio and playlist tracks to alternate endpoints',
      () async {
        when(
          () => datasource.fetchPlaylistDetail(
            'radio-1',
            currentUserId: any(named: 'currentUserId'),
            currentUserName: any(named: 'currentUserName'),
          ),
        ).thenAnswer((_) async => _trackRadio);
        when(
          () => datasource.fetchRadioTracks('radio-1'),
        ).thenAnswer((_) async => []);
        when(
          () => datasource.fetchPlaylistTracks('radio-1'),
        ).thenAnswer((_) async => [_tracks.first]);

        when(
          () => datasource.fetchPlaylistDetail(
            'mix-1',
            currentUserId: any(named: 'currentUserId'),
            currentUserName: any(named: 'currentUserName'),
          ),
        ).thenAnswer((_) async => _mix);
        when(
          () => datasource.fetchPlaylistTracks('mix-1'),
        ).thenAnswer((_) async => []);
        when(
          () => datasource.fetchMixTracks('mix-1'),
        ).thenAnswer((_) async => [_tracks.last]);

        final container = _container(datasource);
        await container.read(playlistDetailProvider.notifier).init('radio-1');
        expect(
          container.read(playlistDetailProvider).tracks.single.id,
          'track-1',
        );

        await container.read(playlistDetailProvider.notifier).init('mix-1');
        expect(
          container.read(playlistDetailProvider).tracks.single.id,
          'track-2',
        );
      },
    );

    test(
      'toggleLike calls unlike for liked playlists and keeps successful state',
      () async {
        when(
          () => datasource.fetchPlaylistDetail(
            'playlist-1',
            currentUserId: any(named: 'currentUserId'),
            currentUserName: any(named: 'currentUserName'),
          ),
        ).thenAnswer((_) async => _playlist.copyWith(isLiked: true));
        when(
          () => datasource.fetchPlaylistTracks('playlist-1'),
        ).thenAnswer((_) async => _tracks);
        when(
          () => datasource.unlikePlaylist('playlist-1'),
        ).thenAnswer((_) async {});

        final container = _container(datasource);
        await container
            .read(playlistDetailProvider.notifier)
            .init('playlist-1');
        await container.read(playlistDetailProvider.notifier).toggleLike();

        expect(
          container.read(playlistDetailProvider).playlist?.isLiked,
          isFalse,
        );
        verify(() => datasource.unlikePlaylist('playlist-1')).called(1);
      },
    );

    test('addSuggestion refreshes tracks and suggestions on success', () async {
      final suggestion = _suggestionTrack();
      when(
        () => datasource.fetchPlaylistDetail(
          'playlist-1',
          currentUserId: any(named: 'currentUserId'),
          currentUserName: any(named: 'currentUserName'),
        ),
      ).thenAnswer((_) async => _playlist);
      when(
        () => datasource.fetchPlaylistTracks('playlist-1'),
      ).thenAnswer((_) async => [_tracks.first]);
      when(
        () => datasource.fetchRecommendedTracksExcluding(
          excludeIds: any(named: 'excludeIds'),
          limit: any(named: 'limit'),
        ),
      ).thenAnswer((_) async => [suggestion]);
      when(
        () => datasource.addTrackToPlaylist(
          playlistId: 'playlist-1',
          trackId: 'suggestion-1',
        ),
      ).thenAnswer((_) async {});

      final container = _container(datasource);
      await container.read(playlistDetailProvider.notifier).init('playlist-1');
      await container
          .read(playlistDetailProvider.notifier)
          .loadSuggestionsIfOwner();

      when(
        () => datasource.fetchPlaylistTracks('playlist-1'),
      ).thenAnswer((_) async => [_tracks.first, suggestion]);
      when(
        () => datasource.fetchRecommendedTracksExcluding(
          excludeIds: ['track-1', 'suggestion-1'],
          limit: 5,
        ),
      ).thenAnswer((_) async => []);

      await container
          .read(playlistDetailProvider.notifier)
          .addSuggestion(suggestion);

      final state = container.read(playlistDetailProvider);
      expect(state.tracks.map((t) => t.id), ['track-1', 'suggestion-1']);
      expect(state.suggestions, isEmpty);
    });

    test(
      'addSuggestion restores suggestion and sets error when API rejects it',
      () async {
        final suggestion = _suggestionTrack();
        when(
          () => datasource.fetchPlaylistDetail(
            'playlist-1',
            currentUserId: any(named: 'currentUserId'),
            currentUserName: any(named: 'currentUserName'),
          ),
        ).thenAnswer((_) async => _playlist);
        when(
          () => datasource.fetchPlaylistTracks('playlist-1'),
        ).thenAnswer((_) async => [_tracks.first]);
        when(
          () => datasource.fetchRecommendedTracksExcluding(
            excludeIds: any(named: 'excludeIds'),
            limit: any(named: 'limit'),
          ),
        ).thenAnswer((_) async => [suggestion]);
        when(
          () => datasource.addTrackToPlaylist(
            playlistId: 'playlist-1',
            trackId: 'suggestion-1',
          ),
        ).thenThrow(_dioError('/playlists/playlist-1/tracks', 403));

        final container = _container(datasource);
        await container
            .read(playlistDetailProvider.notifier)
            .init('playlist-1');
        await container
            .read(playlistDetailProvider.notifier)
            .loadSuggestionsIfOwner();
        await container
            .read(playlistDetailProvider.notifier)
            .addSuggestion(suggestion);

        final state = container.read(playlistDetailProvider);
        expect(state.suggestions.single.id, 'suggestion-1');
        expect(state.error, 'Could not add "Two". Try again.');
      },
    );

    test(
      'refreshSuggestions and reload use existing state and current playlist id',
      () async {
        when(
          () => datasource.fetchPlaylistDetail(
            'playlist-1',
            currentUserId: any(named: 'currentUserId'),
            currentUserName: any(named: 'currentUserName'),
          ),
        ).thenAnswer((_) async => _playlist);
        when(
          () => datasource.fetchPlaylistTracks('playlist-1'),
        ).thenAnswer((_) async => [_tracks.first]);
        when(
          () => datasource.fetchRecommendedTracksExcluding(
            excludeIds: ['track-1'],
            limit: 5,
          ),
        ).thenAnswer((_) async => [_tracks.last]);

        final container = _container(datasource);
        final notifier = container.read(playlistDetailProvider.notifier);
        await notifier.init('playlist-1');
        await notifier.refreshSuggestions();

        expect(
          container.read(playlistDetailProvider).suggestions.single.id,
          'track-2',
        );

        notifier.reload();
        await Future<void>.delayed(Duration.zero);
        verify(
          () => datasource.fetchPlaylistDetail(
            'playlist-1',
            currentUserId: any(named: 'currentUserId'),
            currentUserName: any(named: 'currentUserName'),
          ),
        ).called(2);
      },
    );
  });
}
