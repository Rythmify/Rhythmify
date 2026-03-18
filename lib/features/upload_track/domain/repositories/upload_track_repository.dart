
import 'dart:io';
import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/track_draft.dart';

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