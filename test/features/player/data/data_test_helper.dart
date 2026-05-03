import 'package:mocktail/mocktail.dart';
import 'package:dio/dio.dart';
import 'package:hive/hive.dart';
import 'package:just_audio/just_audio.dart';
import 'package:rythmify/core/network/api_client.dart';
import 'package:rythmify/features/player/data/datasources/playback_local_data_source.dart';
import 'package:rythmify/features/player/data/datasources/playback_remote_data_source.dart';
import 'package:rythmify/features/player/data/datasources/audio_handler.dart';
import 'package:rythmify/features/player/data/models/history_record_model.dart';
import 'package:rythmify/core/domain/entities/track.dart';
import 'package:rythmify/features/player/domain/entities/history_record.dart';

class MockApiClient extends Mock implements ApiClient {}

class MockDio extends Mock implements Dio {}

class MockBox extends Mock implements Box {}

class MockPlaybackRemoteDataSource extends Mock
    implements PlaybackRemoteDataSource {}

class MockPlaybackLocalDataSource extends Mock
    implements PlaybackLocalDataSource {}

class MockRythmifyAudioHandler extends Mock implements RythmifyAudioHandler {}

class MockAudioPlayer extends Mock implements AudioPlayer {}

class MockResponse extends Mock implements Response {}

class FakeHistoryRecordModel extends Fake implements HistoryRecordModel {}

class FakeTrack extends Fake implements Track {}

class FakeAudioSource extends Fake implements AudioSource {}

void registerTestFallbacks() {
  registerFallbackValue(FakeHistoryRecordModel());
  registerFallbackValue(FakeTrack());
  registerFallbackValue(FakeAudioSource());
  registerFallbackValue(Duration.zero);
}
