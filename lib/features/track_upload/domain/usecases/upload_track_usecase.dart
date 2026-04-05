/// UseCase: UploadTrackUseCase
///
/// Handles the full track upload process.
///
/// Responsibilities:
/// - Validate track data before upload
/// - Prepare audio and artwork files
/// - Call repository to perform upload
///
/// Flow:
/// 1. Validate TrackDraft fields
/// 2. Convert paths to File objects
/// 3. Trigger upload via repository
///
/// Returns:
/// - Track ID on success
/// - Failure on error
///
/// Notes:
/// - Contains business validation rules
/// - Acts as the main entry point for uploading
import 'dart:io';
import 'package:dartz/dartz.dart';
import 'package:rythmify/core/error/failures.dart';
import 'package:rythmify/features/track_upload/domain/entities/track_draft.dart';
import 'package:rythmify/features/track_upload/domain/repositories/upload_track_repository.dart';

class UploadTrackUseCase {
  final UploadTrackRepository repository;

  const UploadTrackUseCase(this.repository);

  Future<Either<Failure, String>> call({
    required TrackDraft draft,
    void Function(double progress)? onProgress,
  }) async {
    // ── Step 1: Validate ───────────────────────────────────────────
    final validation = _validate(draft);
    if (validation != null) return Left(validation);

    // ── Step 2: Prepare files ──────────────────────────────────────
    final audioFile = File(draft.localAudioPath);
    final artworkFile = draft.localArtworkPath != null
        ? File(draft.localArtworkPath!)
        : null;

    // Double-check audio file still exists on device
    //commented for teting will uncomment later
    if (!audioFile.existsSync()) {
      return const Left(
        FileFailure('Audio file no longer exists on your device.'),
      );
    }

    // ── Step 3: Upload ─────────────────────────────────────────────
    return repository.uploadTrack(
      draft: draft,
      audioFile: audioFile,
      artworkFile: artworkFile,
      onProgress: onProgress,
    );
  }

  // ── Validation rules ───────────────────────────────────────────────
  ValidationFailure? _validate(TrackDraft draft) {
    if (draft.title == null || draft.title!.trim().isEmpty) {
      return const ValidationFailure('Track title is required.');
    }
    if (draft.artist == null || draft.artist!.trim().isEmpty) {
      return const ValidationFailure('Artist name is required.');
    }
    if (draft.genre == null || draft.genre!.trim().isEmpty) {
      return const ValidationFailure('Please select a genre.');
    }
    if (draft.localAudioPath.trim().isEmpty) {
      return const ValidationFailure('No audio file selected.');
    }
    if (draft.duration == Duration.zero) {
      return const ValidationFailure('Could not detect audio duration.');
    }
    return null; // all good
  }
}
