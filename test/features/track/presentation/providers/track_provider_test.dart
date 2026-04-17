import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:dartz/dartz.dart';
import 'package:rythmify/core/domain/entities/track.dart';
import 'package:rythmify/core/errors/failures.dart';
import 'package:rythmify/features/profile/domain/entities/profile_entity.dart';
import 'package:rythmify/features/profile/domain/usecases/get_profile_usecase.dart';
import 'package:rythmify/features/track/domain/usecases/get_track_details.dart';
import 'package:rythmify/features/track/domain/usecases/get_tracks.dart';
import 'package:rythmify/features/track/presentation/providers/track_dependency_providers.dart';
import 'package:rythmify/features/track/presentation/providers/track_provider.dart';

class MockGetTrackDetails extends Mock implements GetTrackDetails {}

class MockGetProfileUseCase extends Mock implements GetProfileUseCase {}

class MockGetTracks extends Mock implements GetTracks {}

void main() {
  late ProviderContainer container;
  late MockGetTrackDetails mockGetTrackDetails;
  late MockGetProfileUseCase mockGetProfileUseCase;
  late MockGetTracks mockGetTracks;

  final tTrack = Track(
    id: 'track-123',
    userId: 'user-789',
    title: 'Awesome Track',
    artist: 'John Doe',
    audioUrl: 'https://example.com/audio.mp3',
    duration: const Duration(minutes: 3),
    createdAt: DateTime(2023, 10, 15),
  );

  final tProfile = ProfileEntity(
    id: 'user-789',
    displayName: 'Super John',
    avatarUrl: 'https://example.com/avatar.jpg',
    city: 'New York',
    country: 'USA',
    followersCount: 100,
    followingCount: 50,
    tracksCount: 10,
    isFollowing: false,
  );

  setUp(() {
    mockGetTrackDetails = MockGetTrackDetails();
    mockGetProfileUseCase = MockGetProfileUseCase();
    mockGetTracks = MockGetTracks();

    container = ProviderContainer(
      overrides: [
        getTrackDetailsUseCaseProvider.overrideWithValue(mockGetTrackDetails),
        getProfileUseCaseProvider.overrideWithValue(mockGetProfileUseCase),
        getTracksUseCaseProvider.overrideWithValue(mockGetTracks),
      ],
    );
  });

  tearDown(() {
    container.dispose();
  });

  group('trackDetailsProvider', () {
    test(
      'should fetch track and populate artist details from profile',
      () async {
        when(
          () => mockGetTrackDetails.call(any()),
        ).thenAnswer((_) async => tTrack);
        when(
          () => mockGetProfileUseCase.call(userId: any(named: 'userId')),
        ).thenAnswer((_) async => Right(tProfile));

        final result = await container.read(
          trackDetailsProvider('track-123').future,
        );

        expect(result.id, 'track-123');
        expect(result.artist, 'Super John'); // Populated from profile
        expect(result.artistPfp, 'https://example.com/avatar.jpg');
        expect(result.artistCity, 'New York');
        expect(result.artistCountry, 'USA');

        verify(() => mockGetTrackDetails.call('track-123')).called(1);
        verify(() => mockGetProfileUseCase.call(userId: 'user-789')).called(1);
      },
    );

    test('should return track as is if profile fetch fails', () async {
      when(
        () => mockGetTrackDetails.call(any()),
      ).thenAnswer((_) async => tTrack);
      when(
        () => mockGetProfileUseCase.call(userId: any(named: 'userId')),
      ).thenAnswer((_) async => const Left(ServerFailure('Error')));

      final result = await container.read(
        trackDetailsProvider('track-123').future,
      );

      expect(result.id, 'track-123');
      expect(result.artist, 'John Doe'); // Original from track
      expect(result.artistPfp, isNull);

      verify(() => mockGetTrackDetails.call('track-123')).called(1);
      verify(() => mockGetProfileUseCase.call(userId: 'user-789')).called(1);
    });
  });

  group('allTracksProvider', () {
    test('should return list of tracks from getTracks usecase', () async {
      when(() => mockGetTracks.call()).thenAnswer((_) async => [tTrack]);

      final result = await container.read(allTracksProvider.future);

      expect(result, [tTrack]);
      verify(() => mockGetTracks.call()).called(1);
    });
  });
}
