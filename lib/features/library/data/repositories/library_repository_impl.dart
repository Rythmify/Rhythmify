import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/domain/entities/track.dart';
import '../../../../core/data/models/track_dto.dart';
import '../../domain/entities/library_entities.dart';
import '../../domain/repositories/library_repository.dart';
import '../datasources/library_remote_datasource.dart';

/// Concrete implementation of [LibraryRepository].
///
/// Maps datasource results to domain entities and converts
/// exceptions into typed [Failure] objects.
class LibraryRepositoryImpl implements LibraryRepository {
  final LibraryRemoteDatasource remoteDatasource;

  LibraryRepositoryImpl({required this.remoteDatasource});

  // ── Following ──────────────────────────────────────────────────────────────

  @override
  Future<Either<Failure, List<FollowedUser>>> getFollowing({
    required int page,
    required int limit,
  }) async {
    try {
      final result = await remoteDatasource.getFollowing(
        page: page,
        limit: limit,
      );
      return Right(result);
    } catch (e) {
      return Left(_map(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> unfollowUser({required String userId}) async {
    try {
      await remoteDatasource.unfollowUser(userId: userId);
      return const Right(null);
    } catch (e) {
      return Left(_map(e.toString()));
    }
  }

  // ── Playlists ──────────────────────────────────────────────────────────────

  @override
  Future<Either<Failure, List<LibraryPlaylist>>> getMyPlaylists() async {
    try {
      final result = await remoteDatasource.getMyPlaylists();
      return Right(result);
    } catch (e) {
      return Left(_map(e.toString()));
    }
  }

  @override
  Future<Either<Failure, LibraryPlaylist>> createPlaylist({
    required String name,
    String? description,
    required bool isPublic,
  }) async {
    try {
      final result = await remoteDatasource.createPlaylist(
        name: name,
        description: description,
        isPublic: isPublic,
      );
      return Right(result);
    } catch (e) {
      return Left(_map(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deletePlaylist({
    required String playlistId,
  }) async {
    try {
      await remoteDatasource.deletePlaylist(playlistId: playlistId);
      return const Right(null);
    } catch (e) {
      return Left(_map(e.toString()));
    }
  }

  // ── Uploads ────────────────────────────────────────────────────────────────

  @override
  Future<Either<Failure, List<UploadedTrack>>> getMyUploads({
    required int page,
    required int limit,
  }) async {
    try {
      final result = await remoteDatasource.getMyUploads(
        page: page,
        limit: limit,
      );
      return Right(result);
    } catch (e) {
      return Left(_map(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> toggleTrackVisibility({
    required String trackId,
    required bool isPublic,
  }) async {
    try {
      await remoteDatasource.toggleTrackVisibility(
        trackId: trackId,
        isPublic: isPublic,
      );
      return const Right(null);
    } catch (e) {
      return Left(_map(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteTrack({required String trackId}) async {
    try {
      await remoteDatasource.deleteTrack(trackId: trackId);
      return const Right(null);
    } catch (e) {
      return Left(_map(e.toString()));
    }
  }

  // ── Insights ───────────────────────────────────────────────────────────────

  @override
  Future<Either<Failure, List<TrackInsight>>> getMyInsights() async {
    try {
      final result = await remoteDatasource.getMyInsights();
      return Right(result);
    } catch (e) {
      return Left(_map(e.toString()));
    }
  }

  // ── History ────────────────────────────────────────────────────────────────

  @override
  Future<Either<Failure, List<RecentlyPlayedEntry>>> getRecentlyPlayed() async {
    try {
      final result = await remoteDatasource.getRecentlyPlayed();
      return Right(result);
    } catch (e) {
      return Left(_map(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<RecentlyPlayedEntry>>> getListeningHistory({
    required int page,
    required int limit,
  }) async {
    try {
      final result = await remoteDatasource.getListeningHistory(
        page: page,
        limit: limit,
      );
      return Right(result);
    } catch (e) {
      return Left(_map(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> clearListeningHistory() async {
    try {
      await remoteDatasource.clearListeningHistory();
      return const Right(null);
    } catch (e) {
      return Left(_map(e.toString()));
    }
  }

  // ── Stations ───────────────────────────────────────────────────────────────

  @override
  Future<Either<Failure, List<LibraryStation>>> getStations() async {
    try {
      final result = await remoteDatasource.getStations();
      return Right(result);
    } catch (e) {
      return Left(_map(e.toString()));
    }
  }

  // ── Liked tracks ───────────────────────────────────────────────────────────

  @override
  Future<Either<Failure, List<Track>>> getLikedTracks({
    required int page,
    required int limit,
  }) async {
    try {
      final result = await remoteDatasource.getLikedTracks(
        page: page,
        limit: limit,
      );
      // Convert UploadedTrackModel → Track entity using TrackDto mapping
      final tracks = result
          .map(
            (t) => TrackDto.fromJson({
              'id': t.id,
              'title': t.title,
              'artist': '',
              'artwork_url': t.artworkUrl,
              'audio_url': '',
              'duration': 0,
              'play_count': t.playCount,
              'like_count': t.likeCount,
              'is_liked': true,
              'status': t.status,
              'created_at': t.createdAt.toIso8601String(),
            }),
          )
          .toList();
      return Right(tracks);
    } catch (e) {
      return Left(_map(e.toString()));
    }
  }

  // ── Error mapping ──────────────────────────────────────────────────────────

  Failure _map(String error) {
    if (error.contains('RESOURCE_NOT_FOUND')) {
      return const ServerFailure('Resource not found.');
    }
    if (error.contains('PERMISSION_DENIED')) {
      return const ServerFailure('Permission denied.');
    }
    if (error.contains('RATE_LIMIT_EXCEEDED')) {
      return const TooManyRequestsFailure();
    }
    if (error.contains('network') || error.contains('socket')) {
      return const NetworkFailure();
    }
    return ServerFailure(error);
  }
}
