import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:rythmify/features/library/domain/entities/library_entities.dart';
import 'package:rythmify/features/library/domain/repositories/library_repository.dart';
import 'package:rythmify/features/library/domain/usecases/library_usecases.dart';

class MockLibraryRepository extends Mock implements LibraryRepository {}

void main() {
  late MockLibraryRepository repository;

  setUp(() {
    repository = MockLibraryRepository();
  });

  test('GetFollowingUseCase forwards default pagination', () async {
    when(
      () => repository.getFollowing(page: 1, limit: 20),
    ).thenAnswer((_) async => const Right(<FollowedUser>[]));

    await GetFollowingUseCase(repository).call();

    verify(() => repository.getFollowing(page: 1, limit: 20)).called(1);
  });

  test('Following/playlist/upload usecases forward parameters', () async {
    when(
      () => repository.unfollowUser(userId: 'u1'),
    ).thenAnswer((_) async => const Right(null));
    when(
      () => repository.getMyPlaylists(),
    ).thenAnswer((_) async => const Right(<LibraryPlaylist>[]));
    when(
      () => repository.createPlaylist(
        name: 'N',
        description: 'D',
        isPublic: true,
      ),
    ).thenAnswer((_) async => Right(_playlist()));
    when(
      () => repository.deletePlaylist(playlistId: 'p1'),
    ).thenAnswer((_) async => const Right(null));
    when(
      () => repository.getMyUploads(page: 2, limit: 5),
    ).thenAnswer((_) async => const Right(<UploadedTrack>[]));
    when(
      () => repository.toggleTrackVisibility(trackId: 't1', isPublic: false),
    ).thenAnswer((_) async => const Right(null));
    when(
      () => repository.deleteTrack(trackId: 't1'),
    ).thenAnswer((_) async => const Right(null));

    await UnfollowUserLibraryUseCase(repository).call(userId: 'u1');
    await GetMyPlaylistsUseCase(repository).call();
    await CreatePlaylistUseCase(
      repository,
    ).call(name: 'N', description: 'D', isPublic: true);
    await DeletePlaylistUseCase(repository).call(playlistId: 'p1');
    await GetMyUploadsUseCase(repository).call(page: 2, limit: 5);
    await ToggleTrackVisibilityUseCase(
      repository,
    ).call(trackId: 't1', isPublic: false);
    await DeleteTrackUseCase(repository).call(trackId: 't1');

    verify(() => repository.unfollowUser(userId: 'u1')).called(1);
    verify(() => repository.getMyPlaylists()).called(1);
    verify(
      () => repository.createPlaylist(
        name: 'N',
        description: 'D',
        isPublic: true,
      ),
    ).called(1);
    verify(() => repository.deletePlaylist(playlistId: 'p1')).called(1);
    verify(() => repository.getMyUploads(page: 2, limit: 5)).called(1);
    verify(
      () => repository.toggleTrackVisibility(trackId: 't1', isPublic: false),
    ).called(1);
    verify(() => repository.deleteTrack(trackId: 't1')).called(1);
  });

  test('Insights/history/stations/liked usecases forward calls', () async {
    when(
      () => repository.getMyInsights(),
    ).thenAnswer((_) async => const Right(<TrackInsight>[]));
    when(
      () => repository.getRecentlyPlayed(),
    ).thenAnswer((_) async => const Right(<RecentlyPlayedEntry>[]));
    when(
      () => repository.getListeningHistory(page: 1, limit: 20),
    ).thenAnswer((_) async => const Right(<RecentlyPlayedEntry>[]));
    when(
      () => repository.clearListeningHistory(),
    ).thenAnswer((_) async => const Right(null));
    when(
      () => repository.getStations(),
    ).thenAnswer((_) async => const Right(<LibraryStation>[]));
    when(
      () => repository.getLikedTracks(page: 1, limit: 20),
    ).thenAnswer((_) async => const Right(<LikedTrack>[]));

    await GetMyInsightsUseCase(repository).call();
    await GetRecentlyPlayedUseCase(repository).call();
    await GetListeningHistoryUseCase(repository).call();
    await ClearListeningHistoryUseCase(repository).call();
    await GetStationsUseCase(repository).call();
    await GetLikedTracksLibraryUseCase(repository).call();

    verify(() => repository.getMyInsights()).called(1);
    verify(() => repository.getRecentlyPlayed()).called(1);
    verify(() => repository.getListeningHistory(page: 1, limit: 20)).called(1);
    verify(() => repository.clearListeningHistory()).called(1);
    verify(() => repository.getStations()).called(1);
    verify(() => repository.getLikedTracks(page: 1, limit: 20)).called(1);
  });
}

LibraryPlaylist _playlist() => LibraryPlaylist(
  id: 'p1',
  name: 'P',
  trackCount: 0,
  likeCount: 0,
  isPublic: true,
  isOwned: true,
  createdAt: DateTime(2026, 1, 1),
);
