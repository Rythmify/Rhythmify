import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:rythmify/core/errors/failures.dart';
import 'package:rythmify/features/library/data/datasources/library_remote_datasource.dart';
import 'package:rythmify/features/library/data/models/library_models.dart';
import 'package:rythmify/features/library/data/repositories/library_repository_impl.dart';

class MockLibraryRemoteDatasource extends Mock
    implements LibraryRemoteDatasource {}

void main() {
  late MockLibraryRemoteDatasource datasource;
  late LibraryRepositoryImpl repository;

  setUp(() {
    datasource = MockLibraryRemoteDatasource();
    repository = LibraryRepositoryImpl(remoteDatasource: datasource);
  });

  final followed = FollowedUserModel(
    id: 'u1',
    displayName: 'User',
    followersCount: 1,
  );
  final playlist = LibraryPlaylistModel(
    id: 'p1',
    name: 'P',
    trackCount: 0,
    likeCount: 0,
    isPublic: true,
    isOwned: true,
    createdAt: DateTime(2026, 1, 1),
  );
  final upload = UploadedTrackModel(
    id: 't1',
    title: 'T',
    playCount: 10,
    likeCount: 5,
    isPublic: true,
    status: 'ready',
    createdAt: DateTime(2026, 1, 1),
  );
  final insight = const TrackInsightModel(
    trackId: 't1',
    title: 'T',
    totalPlays: 10,
    uniqueListeners: 5,
    likes: 5,
    reposts: 1,
    comments: 1,
  );
  final history = RecentlyPlayedEntryModel(
    trackId: 't1',
    title: 'T',
    artistName: 'A',
    durationSeconds: 120,
    playedAt: DateTime(2026, 1, 1),
  );
  final station = const LibraryStationModel(
    id: 's1',
    name: 'S',
    seedArtistName: 'A',
    trackCount: 50,
  );

  test('getFollowing returns right on success', () async {
    when(
      () => datasource.getFollowing(page: 1, limit: 20),
    ).thenAnswer((_) async => [followed]);

    final result = await repository.getFollowing(page: 1, limit: 20);

    expect(result.isRight(), true);
  });

  test(
    'getFollowing maps RATE_LIMIT_EXCEEDED to TooManyRequestsFailure',
    () async {
      when(
        () => datasource.getFollowing(page: 1, limit: 20),
      ).thenThrow(Exception('RATE_LIMIT_EXCEEDED'));

      final result = await repository.getFollowing(page: 1, limit: 20);

      expect(result.isLeft(), true);
      expect((result as Left).value, isA<TooManyRequestsFailure>());
    },
  );

  test('playlist and uploads operations return right on success', () async {
    when(() => datasource.getMyPlaylists()).thenAnswer((_) async => [playlist]);
    when(
      () => datasource.createPlaylist(
        name: 'New',
        description: null,
        isPublic: true,
      ),
    ).thenAnswer((_) async => playlist);
    when(
      () => datasource.deletePlaylist(playlistId: 'p1'),
    ).thenAnswer((_) async {});
    when(
      () => datasource.getMyUploads(page: 1, limit: 20),
    ).thenAnswer((_) async => [upload]);
    when(
      () => datasource.toggleTrackVisibility(trackId: 't1', isPublic: false),
    ).thenAnswer((_) async {});
    when(() => datasource.deleteTrack(trackId: 't1')).thenAnswer((_) async {});

    expect((await repository.getMyPlaylists()).isRight(), true);
    expect(
      (await repository.createPlaylist(
        name: 'New',
        description: null,
        isPublic: true,
      )).isRight(),
      true,
    );
    expect((await repository.deletePlaylist(playlistId: 'p1')).isRight(), true);
    expect((await repository.getMyUploads(page: 1, limit: 20)).isRight(), true);
    expect(
      (await repository.toggleTrackVisibility(
        trackId: 't1',
        isPublic: false,
      )).isRight(),
      true,
    );
    expect((await repository.deleteTrack(trackId: 't1')).isRight(), true);
  });

  test('insights, history, stations return right on success', () async {
    when(() => datasource.getMyInsights()).thenAnswer((_) async => [insight]);
    when(
      () => datasource.getRecentlyPlayed(),
    ).thenAnswer((_) async => [history]);
    when(
      () => datasource.getListeningHistory(page: 1, limit: 20),
    ).thenAnswer((_) async => [history]);
    when(() => datasource.clearListeningHistory()).thenAnswer((_) async {});
    when(() => datasource.getStations()).thenAnswer((_) async => [station]);
    when(
      () => datasource.getLikedTracks(page: 1, limit: 20),
    ).thenAnswer((_) async => [upload]);

    expect((await repository.getMyInsights()).isRight(), true);
    expect((await repository.getRecentlyPlayed()).isRight(), true);
    expect(
      (await repository.getListeningHistory(page: 1, limit: 20)).isRight(),
      true,
    );
    expect((await repository.clearListeningHistory()).isRight(), true);
    expect((await repository.getStations()).isRight(), true);
    expect(
      (await repository.getLikedTracks(page: 1, limit: 20)).isRight(),
      true,
    );
  });

  test('map network errors to NetworkFailure', () async {
    when(() => datasource.getStations()).thenThrow(Exception('socket timeout'));

    final result = await repository.getStations();

    expect(result.isLeft(), true);
    expect((result as Left).value, isA<NetworkFailure>());
  });
}
