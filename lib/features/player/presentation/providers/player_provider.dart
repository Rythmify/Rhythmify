import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:audio_service/audio_service.dart';
import '../../../../core/domain/entities/track_summary.dart';
import '../../domain/entities/player_state.dart';
import '../../domain/repositories/audio_repository.dart';
import '../../data/datasources/audio_handler.dart';
import '../../data/repositories/audio_repository_impl.dart';

part 'player_provider.g.dart';

@Riverpod(keepAlive: true)
Future<AudioRepository> audioRepository(Ref ref) async {
  final audioHandler = await AudioService.init(
    builder: () => RythmifyAudioHandler(),
    config: const AudioServiceConfig(
      androidNotificationChannelId: 'com.rythmify.channel.audio',
      androidNotificationChannelName: 'Audio playback',
      androidNotificationOngoing: true,
    ),
  );
  
  final repository = AudioRepositoryImpl(audioHandler);
  await repository.init();
  return repository;
}

@Riverpod(keepAlive: true)
class PlayerStateNotifier extends _$PlayerStateNotifier {
  @override
  AppPlayerState build() {
    // Listen to repository provider
    ref.listen(audioRepositoryProvider, (previous, next) {
      if (next.hasValue) {
        final repo = next.value!;
        repo.playerStateStream.listen((playerEvent) {
          state = playerEvent;
        });
        // Initial state
        state = repo.currentState;
      }
    });

    return const AppPlayerState();
  }

  Future<void> play() async {
    final repo = await ref.read(audioRepositoryProvider.future);
    await repo.play();
  }

  Future<void> pause() async {
    final repo = await ref.read(audioRepositoryProvider.future);
    await repo.pause();
  }

  Future<void> togglePlayPause() async {
    final repo = await ref.read(audioRepositoryProvider.future);
    if (state.status == PlayerStatus.playing) {
      await repo.pause();
    } else {
      await repo.play();
    }
  }

  Future<void> seek(Duration position) async {
    final repo = await ref.read(audioRepositoryProvider.future);
    await repo.seek(position);
  }

  Future<void> skipToNext() async {
    final repo = await ref.read(audioRepositoryProvider.future);
    await repo.skipToNext();
  }

  Future<void> skipToPrevious() async {
    final repo = await ref.read(audioRepositoryProvider.future);
    await repo.skipToPrevious();
  }

  Future<void> loadAndPlayQueue(List<TrackSummary> tracks, {int initialIndex = 0}) async {
    final repo = await ref.read(audioRepositoryProvider.future);
    await repo.loadQueue(tracks, initialIndex: initialIndex);
    await repo.play();
  }
}

@Riverpod(keepAlive: true)
class QueueNotifier extends _$QueueNotifier {
  @override
  List<TrackSummary> build() {
    ref.listen(audioRepositoryProvider, (previous, next) {
      if (next.hasValue) {
        final repo = next.value!;
        repo.queueStream.listen((queue) {
          state = queue;
        });
        state = repo.currentQueue;
      }
    });
    return [];
  }
}
