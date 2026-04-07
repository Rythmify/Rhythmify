// import 'dart:io';

// import 'package:dartz/dartz.dart';
// import 'package:dio/dio.dart';

// import '../../domain/entities/collection_type.dart';
// import '../../domain/entities/playlist_entity.dart';
// import 'package:rythmify/core/error/failures.dart';
// import '../../domain/entities/playlist_track.dart';
// import '../../domain/entities/station_entity.dart';
// import '../../domain/repositories/playlist_repository.dart';
// import '../datasources/playlist_remote_datasource.dart';
// import '../mock/playlist_mock_data_store.dart';

// /// Concrete implementation of [PlaylistRepository].
// ///
// /// Delegates to [PlaylistRemoteDatasource] for all HTTP calls.
// /// Catches [DioException] and maps HTTP status codes to domain [Failure] types
// /// so the presentation layer never sees raw network exceptions.
// ///
// /// During development, pass [useMock] = true to route calls through
// /// [PlaylistMockStore] instead of the real API.
// class PlaylistRepositoryImpl implements PlaylistRepository {
//   const PlaylistRepositoryImpl({
//     required this.datasource,
//     required this.mockStore,
//     this.useMock = false,
//   });

//   final PlaylistRemoteDatasource datasource;
//   final PlaylistMockStore mockStore;
//   final bool useMock;

//   // ── Create ──────────────────────────────────────────────────────────────

//   @override
//   Future<Either<Failure, PlaylistEntity>> createPlaylist({
//     required String name,
//     required bool isPublic,
//     required CollectionType type,
//   }) async {
//     if (useMock) {
//       return Right(mockStore.create(name: name, isPublic: isPublic, type: type));
//     }
//     return _execute(
//       () => datasource.createPlaylist(
//         name: name,
//         isPublic: isPublic,
//         subtype: subtypeFromCollectionType(type),
//       ),
//     );
//   }

//   // ── Update ────────────────────────────────────────────────────────────────

//   @override
//   Future<Either<Failure, PlaylistEntity>> updatePlaylist({
//     required String playlistId,
//     String? name,
//     String? description,
//     bool? isPublic,
//     File? coverImage,
//     bool removeCover = false,
//     String? subtype,
//     String? releaseDate,
//     String? genreId,
//     List<String>? tags,
//   }) async {
//     if (useMock) {
//       return Right(
//         mockStore.update(playlistId: playlistId, name: name, isPublic: isPublic),
//       );
//     }
//     return _execute(
//       () => datasource.updatePlaylist(
//         playlistId: playlistId,
//         name: name,
//         description: description,
//         isPublic: isPublic,
//         coverImage: coverImage,
//         removeCover: removeCover,
//         subtype: subtype,
//         releaseDate: releaseDate,
//         genreId: genreId,
//         tags: tags,
//       ),
//     );
//   }

//   // ── Delete ────────────────────────────────────────────────────────────────

//   @override
//   Future<Either<Failure, void>> deletePlaylist(String playlistId) async {
//     if (useMock) {
//       mockStore.delete(playlistId);
//       return const Right(null);
//     }
//     return _executeVoid(() => datasource.deletePlaylist(playlistId));
//   }

//   // ── Fetch list ────────────────────────────────────────────────────────────

//   @override
//   Future<Either<Failure, List<PlaylistEntity>>> fetchMyPlaylists({
//     String filter = 'created',
//     bool albumView = false,
//     int limit = 20,
//     int offset = 0,
//   }) async {
//     if (useMock) return Right(mockStore.getAll());
//     return _execute(
//       () => datasource.fetchMyPlaylists(
//         filter: filter,
//         albumView: albumView,
//         limit: limit,
//         offset: offset,
//       ),
//     );
//   }

//   // ── Fetch detail ──────────────────────────────────────────────────────────

//   @override
//   Future<Either<Failure, PlaylistEntity>> fetchPlaylistDetail({
//     required String playlistId,
//     String? secretToken,
//   }) async {
//     if (useMock) {
//       final entity = mockStore.getById(playlistId);
//       if (entity == null) return const Left(PlaylistNotFoundFailure());
//       return Right(entity);
//     }
//     return _execute(
//       () => datasource.fetchPlaylistDetail(
//         playlistId: playlistId,
//         secretToken: secretToken,
//       ),
//     );
//   }

//   // ── Fetch tracks ──────────────────────────────────────────────────────────

//   @override
//   Future<Either<Failure, List<PlaylistTrackItem>>> fetchPlaylistTracks({
//     required String playlistId,
//     String? secretToken,
//     int page = 1,
//     int limit = 20,
//   }) async {
//     if (useMock) return Right(mockStore.getTracks(playlistId));
//     return _execute(
//       () => datasource.fetchPlaylistTracks(
//         playlistId: playlistId,
//         secretToken: secretToken,
//         page: page,
//         limit: limit,
//       ),
//     );
//   }

//   // ── Track management ──────────────────────────────────────────────────────

//   @override
//   Future<Either<Failure, void>> addTrackToPlaylist({
//     required String playlistId,
//     required String trackId,
//     int? position,
//   }) =>
//       _executeVoid(
//         () => datasource.addTrackToPlaylist(
//           playlistId: playlistId,
//           trackId: trackId,
//           position: position,
//         ),
//       );

//   @override
//   Future<Either<Failure, void>> removeTrackFromPlaylist({
//     required String playlistId,
//     required String trackId,
//   }) =>
//       _executeVoid(
//         () => datasource.removeTrackFromPlaylist(
//           playlistId: playlistId,
//           trackId: trackId,
//         ),
//       );

//   @override
//   Future<Either<Failure, void>> reorderPlaylistTracks({
//     required String playlistId,
//     required List<String> orderedTrackIds,
//   }) =>
//       _executeVoid(
//         () => datasource.reorderPlaylistTracks(
//           playlistId: playlistId,
//           orderedTrackIds: orderedTrackIds,
//         ),
//       );

//   // ── Engagement ────────────────────────────────────────────────────────────

//   @override
//   Future<Either<Failure, void>> likePlaylist(String playlistId) =>
//       _executeVoid(() => datasource.likePlaylist(playlistId));

//   @override
//   Future<Either<Failure, void>> unlikePlaylist(String playlistId) =>
//       _executeVoid(() => datasource.unlikePlaylist(playlistId));

//   @override
//   Future<Either<Failure, void>> repostPlaylist(String playlistId) =>
//       _executeVoid(() => datasource.repostPlaylist(playlistId));

//   @override
//   Future<Either<Failure, void>> removePlaylistRepost(String playlistId) =>
//       _executeVoid(() => datasource.removePlaylistRepost(playlistId));

//   // ── Stations ──────────────────────────────────────────────────────────────

//   @override
//   Future<Either<Failure, List<StationEntity>>> fetchStations({
//     int limit = 10,
//     int offset = 0,
//   }) =>
//       _execute(
//         () => datasource.fetchStations(limit: limit, offset: offset),
//       );

//   @override
//   Future<Either<Failure, List<PlaylistTrackItem>>> fetchStationTracks({
//     required String artistId,
//     int limit = 50,
//     int offset = 0,
//   }) =>
//       _execute(
//         () => datasource.fetchStationTracks(
//           artistId: artistId,
//           limit: limit,
//           offset: offset,
//         ),
//       );

//   // ── Error handling helpers ────────────────────────────────────────────────

//   /// Wraps a datasource call that returns a value, converting [DioException]
//   /// to the appropriate [Failure] subtype.
//   Future<Either<Failure, T>> _execute<T>(Future<T> Function() call) async {
//     try {
//       return Right(await call());
//     } on DioException catch (e) {
//       return Left(_mapDioError(e));
//     } catch (_) {
//       return const Left(PlaylistNetworkFailure());
//     }
//   }

//   /// Same as [_execute] but for void-returning calls.
//   Future<Either<Failure, void>> _executeVoid(
//     Future<void> Function() call,
//   ) async {
//     try {
//       await call();
//       return const Right(null);
//     } on DioException catch (e) {
//       return Left(_mapDioError(e));
//     } catch (_) {
//       return const Left(PlaylistNetworkFailure());
//     }
//   }

//   /// Maps [DioException] HTTP status codes to domain [Failure] types.
//   ///
//   /// Matches the error codes defined in the OpenAPI spec for the Playlists module.
//   Failure _mapDioError(DioException e) {
//     final statusCode = e.response?.statusCode;
//     final errorCode = _extractCode(e);

//     switch (statusCode) {
//       case 401:
//         // Auth failures are handled globally by ApiClient — this is a fallback.
//         return const PlaylistNetworkFailure();
//       case 403:
//         if (errorCode == 'PRIVATE_PLAYLIST_ACCESS_DENIED' ||
//             errorCode == 'PLAYLIST_ACCESS_DENIED') {
//           return const PlaylistAccessDeniedFailure();
//         }
//         return const PlaylistForbiddenFailure();
//       case 404:
//         if (errorCode == 'PLAYLIST_NOT_FOUND') {
//           return const PlaylistNotFoundFailure();
//         }
//         return const StationNotFoundFailure();
//       case 409:
//         if (errorCode == 'PLAYLIST_TRACK_ALREADY_EXISTS') {
//           return const TrackAlreadyInPlaylistFailure();
//         }
//         return const PlaylistServerFailure();
//       case 422:
//         if (errorCode == 'BUSINESS_LIMIT_REACHED') {
//           return const PlaylistLimitReachedFailure();
//         }
//         if (errorCode?.contains('POSITION') == true) {
//           return const PlaylistPositionInvalidFailure();
//         }
//         return const PlaylistServerFailure();
//       default:
//         if (e.type == DioExceptionType.connectionError ||
//             e.type == DioExceptionType.receiveTimeout ||
//             e.type == DioExceptionType.sendTimeout) {
//           return const PlaylistNetworkFailure();
//         }
//         return const PlaylistServerFailure();
//     }
//   }

//   String? _extractCode(DioException e) {
//     try {
//       return e.response?.data['error']['code'] as String?;
//     } catch (_) {
//       return null;
//     }
//   }
// }