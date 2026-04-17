import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:rythmify/core/domain/entities/track.dart';
import 'package:rythmify/features/track/domain/repositories/track_repository.dart';
import 'package:rythmify/features/track/domain/usecases/get_tags.dart';
import 'package:rythmify/features/track/domain/usecases/get_track_details.dart';
import 'package:rythmify/features/track/domain/usecases/get_tracks.dart';
import 'package:rythmify/features/track/domain/usecases/get_waveform.dart';
import 'package:rythmify/features/track/domain/usecases/record_play.dart';
import 'package:rythmify/features/track/domain/usecases/toggle_like.dart';
import 'package:rythmify/features/track/domain/usecases/toggle_repost.dart';

class MockTrackRepository extends Mock implements TrackRepository {}

void main() {
  late MockTrackRepository mockRepository;

  setUp(() {
    mockRepository = MockTrackRepository();
  });

  final tTrack = Track(
    id: 'track-123',
    userId: 'user-789',
    title: 'Awesome Track',
    artist: 'John Doe',
    audioUrl: 'https://example.com/audio.mp3',
    duration: const Duration(minutes: 3),
    createdAt: DateTime(2023, 10, 15),
  );

  group('GetTrackDetails', () {
    late GetTrackDetails usecase;

    setUp(() {
      usecase = GetTrackDetails(mockRepository);
    });

    test('should return track details from repository', () async {
      when(
        () => mockRepository.getTrackDetails(any()),
      ).thenAnswer((_) async => tTrack);

      final result = await usecase('track-123');

      expect(result, tTrack);
      verify(() => mockRepository.getTrackDetails('track-123')).called(1);
    });

    test('should throw ArgumentError if id is empty', () async {
      expect(() => usecase(''), throwsArgumentError);
      verifyNever(() => mockRepository.getTrackDetails(any()));
    });
  });

  group('GetTracks', () {
    late GetTracks usecase;

    setUp(() {
      usecase = GetTracks(mockRepository);
    });

    test('should return list of tracks from repository', () async {
      when(() => mockRepository.getTracks()).thenAnswer((_) async => [tTrack]);

      final result = await usecase();

      expect(result, [tTrack]);
      verify(() => mockRepository.getTracks()).called(1);
    });
  });

  group('GetWaveform', () {
    late GetWaveform usecase;

    setUp(() {
      usecase = GetWaveform(mockRepository);
    });

    test('should return list of doubles from repository', () async {
      final tWaveform = [0.1, 0.5, 1.0, 0.2];
      when(
        () => mockRepository.getWaveform(any()),
      ).thenAnswer((_) async => tWaveform);

      final result = await usecase('track-123');

      expect(result, tWaveform);
      verify(() => mockRepository.getWaveform('track-123')).called(1);
    });
  });

  group('GetTags', () {
    late GetTags usecase;

    setUp(() {
      usecase = GetTags(mockRepository);
    });

    test('should return map of tags from repository', () async {
      final tTags = {'tag1': 'Pop', 'tag2': 'Rock'};
      when(() => mockRepository.getTags()).thenAnswer((_) async => tTags);

      final result = await usecase();

      expect(result, tTags);
      verify(() => mockRepository.getTags()).called(1);
    });
  });

  group('RecordPlay', () {
    late RecordPlay usecase;

    setUp(() {
      usecase = RecordPlay(mockRepository);
    });

    test('should call recordPlay on repository', () async {
      when(() => mockRepository.recordPlay(any())).thenAnswer((_) async {});

      await usecase('track-123');

      verify(() => mockRepository.recordPlay('track-123')).called(1);
    });

    test('should return early if id is empty', () async {
      await usecase('');
      verifyNever(() => mockRepository.recordPlay(any()));
    });
  });

  group('ToggleLike', () {
    late ToggleLike usecase;

    setUp(() {
      usecase = ToggleLike(mockRepository);
    });

    test('should call toggleLike on repository with toggled boolean', () async {
      when(
        () => mockRepository.toggleLike(any(), any()),
      ).thenAnswer((_) async {});

      await usecase('track-123', true);

      verify(() => mockRepository.toggleLike('track-123', false)).called(1);
    });

    test('should return early if id is empty', () async {
      await usecase('', true);
      verifyNever(() => mockRepository.toggleLike(any(), any()));
    });
  });

  group('ToggleRepost', () {
    late ToggleRepost usecase;

    setUp(() {
      usecase = ToggleRepost(mockRepository);
    });

    test(
      'should call toggleRepost on repository with toggled boolean',
      () async {
        when(
          () => mockRepository.toggleRepost(any(), any()),
        ).thenAnswer((_) async {});

        await usecase('track-123', false);

        verify(() => mockRepository.toggleRepost('track-123', true)).called(1);
      },
    );

    test('should return early if id is empty', () async {
      await usecase('', false);
      verifyNever(() => mockRepository.toggleRepost(any(), any()));
    });
  });
}
