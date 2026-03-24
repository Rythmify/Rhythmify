/// Domain Repository Interface: UploadTrackRepository
///
/// Defines the contract for track upload operations.
///
/// Responsibilities:
/// - Fetch available tags from backend
/// - Upload audio track with metadata
///
/// Notes:
/// - Returns Either<Failure, Result> for error handling
/// - Implementation is provided in the Data layer
/// - Domain layer does NOT know how data is fetched/uploaded
import 'dart:io';
import 'package:dartz/dartz.dart';
import 'package:rythmify/core/error/failures.dart';
import 'package:rythmify/features/track_upload/domain/entities/track_draft.dart';

abstract class UploadTrackRepository {
  /// Fetches available tags from GET /tags
  Future<Either<Failure, List<String>>> fetchTags();

  /// Uploads the track to POST /tracks
  /// we expect string as track M9 is what deals with the track entity but we only want the track's id
  /// Reports progress via onProgress callback (0.0 → 1.0)
  Future<Either<Failure, String>> uploadTrack({
    required TrackDraft draft,
    required File audioFile,
    File? artworkFile,
    void Function(double progress)? onProgress,
  });
}
