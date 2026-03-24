import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasources/audio_handler.dart';
import '../../data/repositories/audio_repository_impl.dart';
import '../../domain/repositories/audio_repository.dart';
import '../../domain/usecases/play_pause_usecase.dart';
import '../../domain/usecases/skip_track_usecase.dart';
import '../../domain/usecases/seek_position_usecase.dart';
import '../../domain/usecases/get_player_state_stream_usecase.dart';
import '../../domain/usecases/load_queue_usecase.dart';
import '../../domain/usecases/update_track_info_usecase.dart';

// --- DATA Providers ---
final audioHandlerProvider = Provider<RythmifyAudioHandler>((ref) {
  throw UnimplementedError(
    'audioHandlerProvider was not overridden in ProviderScope',
  );
});

final audioRepositoryProvider = Provider<AudioRepository>((ref) {
  final handler = ref.read(audioHandlerProvider);
  return AudioRepositoryImpl(handler);
});

// --- USE CASE Providers ---
final playTrackUseCaseProvider = Provider(
  (ref) => PlayTrackUseCase(ref.read(audioRepositoryProvider)),
);
final pauseTrackUseCaseProvider = Provider(
  (ref) => PauseTrackUseCase(ref.read(audioRepositoryProvider)),
);
final skipNextUseCaseProvider = Provider(
  (ref) => SkipToNextUseCase(ref.read(audioRepositoryProvider)),
);
final skipPrevUseCaseProvider = Provider(
  (ref) => SkipToPreviousUseCase(ref.read(audioRepositoryProvider)),
);
final seekPositionUseCaseProvider = Provider(
  (ref) => SeekPositionUseCase(ref.read(audioRepositoryProvider)),
);
final getPlayerStateStreamUseCaseProvider = Provider(
  (ref) => GetPlayerStateStreamUseCase(ref.read(audioRepositoryProvider)),
);
final loadQueueUseCaseProvider = Provider(
  (ref) => LoadQueueUseCase(ref.read(audioRepositoryProvider)),
);
final updateTrackInfoUseCaseProvider = Provider(
  (ref) => UpdateTrackInfoUseCase(ref.read(audioRepositoryProvider)),
);
