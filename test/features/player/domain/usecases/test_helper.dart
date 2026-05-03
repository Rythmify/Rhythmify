import 'package:mocktail/mocktail.dart';
import 'package:rythmify/features/player/domain/repositories/audio_repository.dart';
import 'package:rythmify/features/player/domain/repositories/playback_repository.dart';
import 'package:rythmify/core/domain/entities/track.dart';
import 'package:rythmify/features/player/domain/entities/history_record.dart';
import 'package:rythmify/features/player/domain/entities/player_state.dart';

class MockAudioRepository extends Mock implements AudioRepository {}

class MockPlaybackRepository extends Mock implements PlaybackRepository {}

class FakeTrack extends Fake implements Track {}

void registerTestFallbackValues() {
  registerFallbackValue(Duration.zero);
  registerFallbackValue(FakeTrack());
}

final dummyTrack = Track(
  id: '1',
  userId: 'user1',
  title: 'Track 1',
  artist: 'Artist 1',
  audioUrl: 'https://example.com/audio1.mp3',
  duration: const Duration(seconds: 210),
  createdAt: DateTime.now(),
);

final dummyTrack2 = Track(
  id: '2',
  userId: 'user1',
  title: 'Track 2',
  artist: 'Artist 1',
  audioUrl: 'https://example.com/audio2.mp3',
  duration: const Duration(seconds: 180),
  createdAt: DateTime.now(),
);

final dummyTracks = [dummyTrack, dummyTrack2];

final dummyHistoryRecord = HistoryRecord(
  trackId: '1',
  playedAt: DateTime.now(),
  durationPlayedSeconds: 30,
);

const dummyPlayerState = AppPlayerState(
  status: PlayerStatus.playing,
  currentTrack: null,
  position: Duration(seconds: 10),
  duration: Duration(seconds: 100),
);
