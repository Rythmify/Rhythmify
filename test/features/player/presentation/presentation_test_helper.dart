import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:rythmify/core/domain/entities/track.dart';
import 'package:rythmify/features/player/domain/repositories/audio_repository.dart';
import 'package:rythmify/features/player/domain/usecases/play_pause_usecase.dart';
import 'package:rythmify/features/player/domain/usecases/skip_track_usecase.dart';
import 'package:rythmify/features/player/domain/usecases/seek_position_usecase.dart';
import 'package:rythmify/features/player/domain/usecases/get_player_state_stream_usecase.dart';
import 'package:rythmify/features/player/domain/usecases/load_queue_usecase.dart';
import 'package:rythmify/features/player/domain/usecases/update_track_info_usecase.dart';
import 'package:rythmify/features/player/domain/usecases/initiate_playback_usecase.dart';
import 'package:rythmify/features/player/domain/usecases/record_listening_history_usecase.dart';
import 'package:rythmify/features/player/domain/usecases/sync_history_usecase.dart';
import 'package:rythmify/features/player/domain/usecases/fetch_queue_context_usecase.dart';
import 'package:rythmify/features/player/domain/usecases/sync_player_state_usecase.dart';
import 'package:rythmify/features/player/domain/usecases/get_related_tracks_usecase.dart';
import 'package:rythmify/features/player/domain/usecases/append_tracks_usecase.dart';
import 'package:rythmify/features/track/domain/usecases/get_track_details.dart';
import 'package:rythmify/features/track/domain/usecases/get_waveform.dart';
import 'package:rythmify/features/player/data/datasources/audio_handler.dart';
import 'package:rythmify/features/track/presentation/providers/track_interaction_provider.dart';
import 'package:rythmify/features/premium/presentation/providers/premium_provider.dart';
import 'package:rythmify/features/player/domain/entities/player_state.dart';
import 'package:rythmify/features/player/domain/entities/history_record.dart';

class MockAudioRepository extends Mock implements AudioRepository {}

class MockRythmifyAudioHandler extends Mock implements RythmifyAudioHandler {}

class MockPlayTrackUseCase extends Mock implements PlayTrackUseCase {}

class MockPauseTrackUseCase extends Mock implements PauseTrackUseCase {}

class MockSkipToNextUseCase extends Mock implements SkipToNextUseCase {}

class MockSkipToPreviousUseCase extends Mock implements SkipToPreviousUseCase {}

class MockSeekPositionUseCase extends Mock implements SeekPositionUseCase {}

class MockGetPlayerStateStreamUseCase extends Mock
    implements GetPlayerStateStreamUseCase {}

class MockLoadQueueUseCase extends Mock implements LoadQueueUseCase {}

class MockUpdateTrackInfoUseCase extends Mock
    implements UpdateTrackInfoUseCase {}

class MockInitiatePlaybackUseCase extends Mock
    implements InitiatePlaybackUseCase {}

class MockRecordListeningHistoryUseCase extends Mock
    implements RecordListeningHistoryUseCase {}

class MockSyncHistoryUseCase extends Mock implements SyncHistoryUseCase {}

class MockFetchQueueContextUseCase extends Mock
    implements FetchQueueContextUseCase {}

class MockSyncPlayerStateUseCase extends Mock
    implements SyncPlayerStateUseCase {}

class MockGetRelatedTracksUseCase extends Mock
    implements GetRelatedTracksUseCase {}

class MockAppendTracksUseCase extends Mock implements AppendTracksUseCase {}

class MockGetTrackDetails extends Mock implements GetTrackDetails {}

class MockGetWaveform extends Mock implements GetWaveform {}

class MockTrackInteractionNotifier extends Mock
    implements TrackInteractionNotifier {}

class MockPremiumNotifier extends Mock implements PremiumNotifier {}

class FakeAppPlayerState extends Fake implements AppPlayerState {}

class FakeTrack extends Fake implements Track {}

class FakeHistoryRecord extends Fake implements HistoryRecord {}

void registerPlayerFallbackValues() {
  registerFallbackValue(FakeAppPlayerState());
  registerFallbackValue(FakeTrack());
  registerFallbackValue(FakeHistoryRecord());
  registerFallbackValue(Duration.zero);
}

final testTrack = Track(
  id: 'track1',
  userId: 'user1',
  title: 'Test Track',
  artist: 'Test Artist',
  audioUrl: 'https://example.com/audio.mp3',
  coverImage: 'https://example.com/cover.jpg',
  duration: const Duration(seconds: 180),
  createdAt: DateTime.now(),
);

final testTrackWithWaveform = testTrack.copyWith(
  waveformData: [0.1, 0.5, 0.2, 0.8],
);
