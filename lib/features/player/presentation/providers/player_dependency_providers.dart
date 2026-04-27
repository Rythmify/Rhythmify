import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/api_client.dart';
import '../../data/datasources/audio_handler.dart';
import '../../data/datasources/playback_local_data_source.dart';
import '../../data/datasources/playback_remote_data_source.dart';
import '../../data/repositories/audio_repository_impl.dart';
import '../../data/repositories/playback_repository_impl.dart';
import '../../domain/repositories/audio_repository.dart';
import '../../domain/repositories/playback_repository.dart';
import '../../domain/usecases/play_pause_usecase.dart';
import '../../domain/usecases/skip_track_usecase.dart';
import '../../domain/usecases/seek_position_usecase.dart';
import '../../domain/usecases/get_player_state_stream_usecase.dart';
import '../../domain/usecases/load_queue_usecase.dart';
import '../../domain/usecases/update_track_info_usecase.dart';
import '../../domain/usecases/initiate_playback_use_case.dart';
import '../../domain/usecases/record_listening_history_use_case.dart';
import '../../domain/usecases/sync_history_use_case.dart';
import '../../domain/usecases/fetch_queue_context_usecase.dart';
import '../../domain/usecases/sync_player_state_usecase.dart';

// --- DATA Providers ---

/// Provides the [RythmifyAudioHandler] instance for background audio management.
///
/// This provider must be overridden in the [ProviderScope] during app initialization.
final audioHandlerProvider = Provider<RythmifyAudioHandler>((ref) {
  throw UnimplementedError(
    'audioHandlerProvider was not overridden in ProviderScope',
  );
});

/// Provides an implementation of [AudioRepository].
///
/// Interacts with the [Data] layer.
/// Depends on [audioHandlerProvider].
final audioRepositoryProvider = Provider<AudioRepository>((ref) {
  final handler = ref.read(audioHandlerProvider);
  return AudioRepositoryImpl(handler);
});

final playbackRemoteDataSourceProvider = Provider<PlaybackRemoteDataSource>((
  ref,
) {
  return PlaybackRemoteDataSourceImpl(apiClient);
});

final playbackLocalDataSourceProvider = Provider<PlaybackLocalDataSource>((
  ref,
) {
  return PlaybackLocalDataSourceImpl();
});

final playbackRepositoryProvider = Provider<PlaybackRepository>((ref) {
  final remote = ref.read(playbackRemoteDataSourceProvider);
  final local = ref.read(playbackLocalDataSourceProvider);
  return PlaybackRepositoryImpl(remote, local);
});

// --- USE CASE Providers ---

/// Provides the [PlayTrackUseCase] to resume playback.
///
/// Depends on [audioRepositoryProvider].
final playTrackUseCaseProvider = Provider(
  (ref) => PlayTrackUseCase(ref.read(audioRepositoryProvider)),
);

/// Provides the [PauseTrackUseCase] to pause playback.
///
/// Depends on [audioRepositoryProvider].
final pauseTrackUseCaseProvider = Provider(
  (ref) => PauseTrackUseCase(ref.read(audioRepositoryProvider)),
);

/// Provides the [SkipToNextUseCase] to navigate forward in the queue.
///
/// Depends on [audioRepositoryProvider].
final skipNextUseCaseProvider = Provider(
  (ref) => SkipToNextUseCase(ref.read(audioRepositoryProvider)),
);

/// Provides the [SkipToPreviousUseCase] to navigate backward in the queue.
///
/// Depends on [audioRepositoryProvider].
final skipPrevUseCaseProvider = Provider(
  (ref) => SkipToPreviousUseCase(ref.read(audioRepositoryProvider)),
);

/// Provides the [SeekPositionUseCase] to change the playback position.
///
/// Depends on [audioRepositoryProvider].
final seekPositionUseCaseProvider = Provider(
  (ref) => SeekPositionUseCase(ref.read(audioRepositoryProvider)),
);

/// Provides the [GetPlayerStateStreamUseCase] to observe player changes.
///
/// Depends on [audioRepositoryProvider].
final getPlayerStateStreamUseCaseProvider = Provider(
  (ref) => GetPlayerStateStreamUseCase(ref.read(audioRepositoryProvider)),
);

/// Provides the [LoadQueueUseCase] to manage the playback queue.
///
/// Depends on [audioRepositoryProvider].
final loadQueueUseCaseProvider = Provider(
  (ref) => LoadQueueUseCase(ref.read(audioRepositoryProvider)),
);

/// Provides the [UpdateTrackInfoUseCase] to update track metadata.
///
/// Depends on [audioRepositoryProvider].
final updateTrackInfoUseCaseProvider = Provider(
  (ref) => UpdateTrackInfoUseCase(ref.read(audioRepositoryProvider)),
);

final initiatePlaybackUseCaseProvider = Provider(
  (ref) => InitiatePlaybackUseCase(ref.read(playbackRepositoryProvider)),
);

final recordListeningHistoryUseCaseProvider = Provider(
  (ref) => RecordListeningHistoryUseCase(ref.read(playbackRepositoryProvider)),
);

final syncHistoryUseCaseProvider = Provider(
  (ref) => SyncHistoryUseCase(ref.read(playbackRepositoryProvider)),
);

final fetchQueueContextUseCaseProvider = Provider(
  (ref) => FetchQueueContextUseCase(ref.read(playbackRepositoryProvider)),
);

final syncPlayerStateUseCaseProvider = Provider(
  (ref) => SyncPlayerStateUseCase(ref.read(playbackRepositoryProvider)),
);
