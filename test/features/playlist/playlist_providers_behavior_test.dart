import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:rythmify/features/playlist/data/datasources/playlist_remote_datasource.dart';
import 'package:rythmify/features/playlist/data/mock/playlist_mock_data.dart';
import 'package:rythmify/features/playlist/domain/entities/playlist_entity.dart';
import 'package:rythmify/features/playlist/domain/entities/playlist_track.dart';
import 'package:rythmify/features/playlist/presentation/providers/playlist_provider.dart';
import 'package:rythmify/features/authentication/presentation/providers/auth_provider.dart';
import 'package:rythmify/features/authentication/presentation/providers/auth_state.dart';

class MockPlaylistRemoteDatasource extends Mock
    implements PlaylistRemoteDatasource {}

class TestAuthNotifier extends AuthNotifier {
  @override
  AuthState build() => const AuthUnauthenticated();
}

final _playlist = PlaylistEntity(
  id: 'playlist-1',
  name: 'Night Drive',
  ownerName: 'Owner',
  ownerId: 'user-1',
  isPublic: true,
  type: PlaylistType.playlist,
  trackCount: 2,
  totalDuration: const Duration(minutes: 6),
  createdAt: DateTime(2024, 1, 1),
  isLiked: false,
);

final _privatePlaylist = _playlist.copyWith(
  id: 'private-1',
  name: 'Private Drafts',
  isPublic: false,
);

final _tracks = [
  PlaylistTrack(
    id: 'track-1',
    title: 'One',
    artistName: 'Artist',
    duration: const Duration(minutes: 3),
    playCount: 10,
    position: 1,
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

DioException _dioError(String path, [int statusCode = 500]) {
  return DioException(
    requestOptions: RequestOptions(path: path),
    response: Response(
      requestOptions: RequestOptions(path: path),
      statusCode: statusCode,
    ),
  );
}

ProviderContainer _container(MockPlaylistRemoteDatasource datasource) {
  final container = ProviderContainer(
    overrides: [
      playlistDatasourceProvider.overrideWithValue(datasource),
      authProvider.overrideWith(TestAuthNotifier.new),
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

  group('PlaylistListNotifier', () {
    test(
      'starts loading then loads owned playlists into state and cache',
      () async {
        when(
          () => datasource.fetchMyPlaylists(filter: 'created'),
        ).thenAnswer((_) async => [_playlist, _privatePlaylist]);

        final container = _container(datasource);
        expect(container.read(playlistListProvider).isLoading, isTrue);

        await container.read(playlistListProvider.notifier).loadPlaylists();

        final state = container.read(playlistListProvider);
        expect(state.isLoading, isFalse);
        expect(state.error, isNull);
        expect(state.playlists.map((p) => p.id), ['playlist-1', 'private-1']);
        expect(PlaylistMockData.instance.getMyPlaylists().map((p) => p.id), [
          'playlist-1',
          'private-1',
        ]);
      },
    );

    test('falls back to cached playlists when refresh fails', () async {
      PlaylistMockData.instance.syncFromBackend([_playlist]);
      when(
        () => datasource.fetchMyPlaylists(filter: 'created'),
      ).thenThrow(_dioError('/playlists'));

      final container = _container(datasource);
      await container.read(playlistListProvider.notifier).loadPlaylists();

      final state = container.read(playlistListProvider);
      expect(state.isLoading, isFalse);
      expect(state.error, 'Could not refresh playlists');
      expect(state.playlists.single.id, 'playlist-1');
    });

    test(
      'loads liked playlists and surfaces failures without stale data',
      () async {
        when(
          () => datasource.fetchLikedPlaylists(),
        ).thenAnswer((_) async => [_privatePlaylist]);

        final container = _container(datasource);
        await container
            .read(playlistListProvider.notifier)
            .loadLikedPlaylists();

        expect(
          container.read(playlistListProvider).playlists.single.isPublic,
          isFalse,
        );

        when(
          () => datasource.fetchLikedPlaylists(),
        ).thenThrow(_dioError('/me/liked-playlists'));
        await container
            .read(playlistListProvider.notifier)
            .loadLikedPlaylists();

        final failed = container.read(playlistListProvider);
        expect(failed.playlists, isEmpty);
        expect(failed.error, 'Could not load liked playlists');
      },
    );

    test(
      'create, update, and delete call datasource then reload state',
      () async {
        when(
          () => datasource.createPlaylist(
            name: any(named: 'name'),
            isPublic: any(named: 'isPublic'),
          ),
        ).thenAnswer((_) async => _privatePlaylist);
        when(
          () => datasource.fetchMyPlaylists(filter: 'created'),
        ).thenAnswer((_) async => [_privatePlaylist]);
        when(
          () => datasource.updatePlaylist(
            playlistId: any(named: 'playlistId'),
            name: any(named: 'name'),
            isPublic: any(named: 'isPublic'),
            description: any(named: 'description'),
          ),
        ).thenAnswer((_) async => _privatePlaylist.copyWith(name: 'Updated'));
        when(
          () => datasource.deletePlaylist('private-1'),
        ).thenAnswer((_) async {});

        final container = _container(datasource);
        final created = await container
            .read(playlistListProvider.notifier)
            .createPlaylist(name: 'Private Drafts', isPublic: false);
        await container
            .read(playlistListProvider.notifier)
            .updatePlaylist(
              playlistId: 'private-1',
              name: 'Updated',
              isPublic: false,
              description: 'desc',
            );
        await container
            .read(playlistListProvider.notifier)
            .deletePlaylist('private-1');

        expect(created?.id, 'private-1');
        verify(
          () => datasource.createPlaylist(
            name: 'Private Drafts',
            isPublic: false,
          ),
        ).called(1);
        verify(
          () => datasource.updatePlaylist(
            playlistId: 'private-1',
            name: 'Updated',
            isPublic: false,
            description: 'desc',
          ),
        ).called(1);
        verify(() => datasource.deletePlaylist('private-1')).called(1);
      },
    );

    test(
      'create returns null when the API rejects unauthorized access',
      () async {
        when(
          () => datasource.createPlaylist(
            name: any(named: 'name'),
            isPublic: any(named: 'isPublic'),
          ),
        ).thenThrow(_dioError('/playlists', 401));

        final container = _container(datasource);
        final created = await container
            .read(playlistListProvider.notifier)
            .createPlaylist(name: 'Nope', isPublic: true);

        expect(created, isNull);
      },
    );
  });

  group('PlaylistDetailNotifier', () {
    test(
      'init loads playlist detail and tracks without auto-loading suggestions',
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
        ).thenAnswer((_) async => _tracks);

        final container = _container(datasource);
        await container
            .read(playlistDetailProvider.notifier)
            .init('playlist-1');

        final state = container.read(playlistDetailProvider);
        expect(state.isLoading, isFalse);
        expect(state.playlist?.id, 'playlist-1');
        expect(state.tracks.map((t) => t.id), ['track-1', 'track-2']);
        expect(state.suggestions, isEmpty);
        expect(state.totalDuration, const Duration(minutes: 7));
      },
    );

    test('loads owner suggestions excluding existing tracks', () async {
      final suggestion = _tracks.first.copyWith(position: 0);
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
      ).thenAnswer((_) async => [suggestion.copyWith(position: 0)]);

      final container = _container(datasource);
      await container.read(playlistDetailProvider.notifier).init('playlist-1');
      await container
          .read(playlistDetailProvider.notifier)
          .loadSuggestionsIfOwner();

      final state = container.read(playlistDetailProvider);
      expect(state.isSuggestionsLoading, isFalse);
      expect(state.suggestions.single.id, 'track-1');
      verify(
        () => datasource.fetchRecommendedTracksExcluding(
          excludeIds: ['track-1'],
          limit: 5,
        ),
      ).called(1);
    });

    test(
      'toggleLike optimistically updates and rolls back on failure',
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
        ).thenAnswer((_) async => _tracks);
        when(
          () => datasource.likePlaylist('playlist-1'),
        ).thenThrow(_dioError('/playlists/playlist-1/like'));

        final container = _container(datasource);
        await container
            .read(playlistDetailProvider.notifier)
            .init('playlist-1');
        await container.read(playlistDetailProvider.notifier).toggleLike();

        expect(
          container.read(playlistDetailProvider).playlist?.isLiked,
          isFalse,
        );
        verify(() => datasource.likePlaylist('playlist-1')).called(1);
      },
    );

    test(
      'removeTrack performs optimistic update and restores cache on failure',
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
        ).thenAnswer((_) async => _tracks);
        when(
          () => datasource.removeTrackFromPlaylist(
            playlistId: 'playlist-1',
            trackId: 'track-1',
          ),
        ).thenThrow(_dioError('/playlists/playlist-1/tracks/track-1'));

        final container = _container(datasource);
        await container
            .read(playlistDetailProvider.notifier)
            .init('playlist-1');
        await container
            .read(playlistDetailProvider.notifier)
            .removeTrack('track-1');

        expect(container.read(playlistDetailProvider).tracks.map((t) => t.id), [
          'track-1',
          'track-2',
        ]);
      },
    );

    test('uses cached detail when API fails and cache exists', () async {
      PlaylistMockData.instance.syncFromBackend([_playlist]);
      PlaylistMockData.instance.clearTracks('playlist-1');
      PlaylistMockData.instance.addTrack(
        playlistId: 'playlist-1',
        track: _tracks.first,
      );
      when(
        () => datasource.fetchPlaylistDetail(
          'playlist-1',
          currentUserId: any(named: 'currentUserId'),
          currentUserName: any(named: 'currentUserName'),
        ),
      ).thenThrow(_dioError('/playlists/playlist-1'));

      final container = _container(datasource);
      await container.read(playlistDetailProvider.notifier).init('playlist-1');

      final state = container.read(playlistDetailProvider);
      expect(state.isLoading, isFalse);
      expect(state.error, 'Showing cached data');
      expect(state.playlist?.id, 'playlist-1');
      expect(state.tracks.single.id, 'track-1');
    });

    test(
      'reports error when invalid playlist id has no cached fallback',
      () async {
        when(
          () => datasource.fetchPlaylistDetail(
            'missing',
            currentUserId: any(named: 'currentUserId'),
            currentUserName: any(named: 'currentUserName'),
          ),
        ).thenThrow(_dioError('/playlists/missing', 404));

        final container = _container(datasource);
        await container.read(playlistDetailProvider.notifier).init('missing');

        final state = container.read(playlistDetailProvider);
        expect(state.isLoading, isFalse);
        expect(state.playlist, isNull);
        expect(state.error, 'Could not load playlist');
      },
    );
  });
}
