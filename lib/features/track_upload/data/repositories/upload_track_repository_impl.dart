/// Repository Implementation: UploadTrackRepositoryImpl
///
/// Implements UploadTrackRepository using remote data source.
///
/// Responsibilities:
/// - Call remote API via UploadTrackRemoteDataSource
/// - Convert API responses into domain-friendly results
/// - Map exceptions to Failure objects
///
/// Notes:
/// - Acts as a bridge between Domain and Data layers
/// - Ensures domain layer does not depend on Dio or API details

import 'dart:io';
import 'package:dartz/dartz.dart';
import 'package:rythmify/core/error/failures.dart';
import 'package:rythmify/features/track_upload/domain/entities/track_draft.dart';
import 'package:rythmify/features/track_upload/domain/repositories/upload_track_repository.dart';
import 'package:rythmify/features/track_upload/data/datasources/upload_track_remote_datasource.dart';

class UploadTrackRepositoryImpl implements UploadTrackRepository {
  final UploadTrackRemoteDataSource _dataSource;

  UploadTrackRepositoryImpl({required UploadTrackRemoteDataSource dataSource})
    : _dataSource = dataSource;

  @override
  Future<Either<Failure, List<String>>> fetchTags() async {
    try {
      final tags = await _dataSource.fetchTags();
      return Right(tags);
    } catch (e) {
      return Left(_mapError(e));
    }
  }

  @override
  Future<Either<Failure, String>> uploadTrack({
    required TrackDraft draft,
    required File audioFile,
    File? artworkFile,
    void Function(double progress)? onProgress,
  }) async {
    try {
      final response = await _dataSource.uploadTrack(
        audioFile: audioFile,
        artworkFile: artworkFile,
        title: draft.title!,
        artist: draft.artist!,
        genre: draft.genre ?? '',
        description: draft.description,
        caption: draft.caption,
        tags: draft.tags,
        isPublic: draft.isPublic,
        onProgress: onProgress,
      );
      return Right(response.id);
    } catch (e) {
      return Left(_mapError(e));
    }
  }

  Failure _mapError(Object e) {
    final message = e.toString();
    if (message.contains('AUTH_401')) return const AuthFailure();
    if (message.contains('UPLOAD_LIMIT_403')) return const UploadLimitFailure();
    if (message.contains('FILE_TOO_LARGE')) return const FileTooLargeFailure();
    if (message.contains('UNSUPPORTED_FILE'))
      return const UnsupportedFileFailure();
    if (message.contains('SocketException')) return const NetworkFailure();
    return UploadFailure(message);
  }
}
