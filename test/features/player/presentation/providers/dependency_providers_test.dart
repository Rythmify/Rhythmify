import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mocktail/mocktail.dart';
import 'package:rythmify/features/player/presentation/providers/player_dependency_providers.dart';
import 'package:rythmify/features/player/data/datasources/audio_handler.dart';
import 'package:rythmify/features/playlist/presentation/providers/playlist_provider.dart';
import 'package:rythmify/features/playlist/data/datasources/playlist_remote_datasource.dart';
import 'package:audio_service/audio_service.dart';
import 'package:just_audio/just_audio.dart';
import 'package:rxdart/rxdart.dart';

class MockRythmifyAudioHandler extends Mock implements RythmifyAudioHandler {}

class MockPlaylistRemoteDatasource extends Mock
    implements PlaylistRemoteDatasource {}

void main() {
  test('dependency providers can be instantiated', () {
    final mockAudioHandler = MockRythmifyAudioHandler();
    final mockPlaylistDataSource = MockPlaylistRemoteDatasource();

    // Use proper subjects and avoid const issues with PlaybackState
    when(
      () => mockAudioHandler.playbackEventStream,
    ).thenAnswer((_) => Stream<PlaybackEvent>.empty());
    when(
      () => mockAudioHandler.mediaItem,
    ).thenAnswer((_) => BehaviorSubject<MediaItem?>());
    when(
      () => mockAudioHandler.currentIndexStream,
    ).thenAnswer((_) => Stream<int?>.empty());
    when(
      () => mockAudioHandler.playbackState,
    ).thenAnswer((_) => BehaviorSubject<PlaybackState>.seeded(PlaybackState()));
    when(() => mockAudioHandler.currentQueue).thenReturn([]);

    final container = ProviderContainer(
      overrides: [
        audioHandlerProvider.overrideWithValue(mockAudioHandler),
        playlistDatasourceProvider.overrideWithValue(mockPlaylistDataSource),
      ],
    );

    expect(container.read(audioRepositoryProvider), isNotNull);
    expect(container.read(playbackRemoteDataSourceProvider), isNotNull);
    expect(container.read(playbackLocalDataSourceProvider), isNotNull);
    expect(container.read(playbackRepositoryProvider), isNotNull);
    expect(container.read(playTrackUseCaseProvider), isNotNull);
    expect(container.read(pauseTrackUseCaseProvider), isNotNull);
    expect(container.read(skipNextUseCaseProvider), isNotNull);
    expect(container.read(skipPrevUseCaseProvider), isNotNull);
    expect(container.read(seekPositionUseCaseProvider), isNotNull);
    expect(container.read(getPlayerStateStreamUseCaseProvider), isNotNull);
    expect(container.read(loadQueueUseCaseProvider), isNotNull);
    expect(container.read(updateTrackInfoUseCaseProvider), isNotNull);
    expect(container.read(initiatePlaybackUseCaseProvider), isNotNull);
    expect(container.read(recordListeningHistoryUseCaseProvider), isNotNull);
    expect(container.read(syncHistoryUseCaseProvider), isNotNull);
    expect(container.read(fetchQueueContextUseCaseProvider), isNotNull);
    expect(container.read(syncPlayerStateUseCaseProvider), isNotNull);
    expect(container.read(getRelatedTracksUseCaseProvider), isNotNull);
    expect(container.read(appendTracksUseCaseProvider), isNotNull);
  });
}
