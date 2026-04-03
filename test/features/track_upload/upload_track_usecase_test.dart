import 'dart:io';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:rythmify/core/error/failures.dart';
import 'package:rythmify/features/track_upload/domain/entities/track_draft.dart';
import 'package:rythmify/features/track_upload/domain/repositories/upload_track_repository.dart';
import 'package:rythmify/features/track_upload/domain/usecases/upload_track_usecase.dart';

//  Mock
class MockUploadTrackRepository extends Mock implements UploadTrackRepository {}

// Fake for TrackDraft
class FakeTrackDraft extends Fake implements TrackDraft {}

TrackDraft _validDraft() {
  return TrackDraft(
    artistId: 'user_001',
    localAudioPath: '/fake/audio.mp3',
    duration: const Duration(seconds: 180),
    title: 'Test',
    artist: 'Test Artist',
    genre: 'Pop',
  );
}

void main() {
  late MockUploadTrackRepository mockRepository;
  late UploadTrackUseCase useCase;

  setUpAll(() {
    // 🔥 REQUIRED FIX
    registerFallbackValue(FakeTrackDraft());
  });

  setUp(() {
    mockRepository = MockUploadTrackRepository();
    useCase = UploadTrackUseCase(mockRepository);
    registerFallbackValue(File('dummy')); //added
  });

  // ── Validation test ─────────────────────────────
  test('returns failure when title empty', () async {
    final draft = TrackDraft(
      artistId: 'user_001',
      localAudioPath: '/fake/audio.mp3',
      duration: const Duration(seconds: 180),
      title: '',
      artist: 'Artist',
      genre: 'Pop',
    );

    final result = await useCase(draft: draft);

    expect(result.isLeft(), true);
  });

  // ── Success test ───────────────────────────────
  test('success test', () async {
    final draft = _validDraft();

    when(
      () => mockRepository.uploadTrack(
        draft: any(named: 'draft'),
        audioFile: any(named: 'audioFile'),
        artworkFile: any(named: 'artworkFile'),
        onProgress: any(named: 'onProgress'),
      ),
    ).thenAnswer((_) async => const Right('track_123'));

    final result = await useCase(draft: draft);

    expect(result.isRight(), true);
  });
}
