
// /// Implements UploadTrackRepository.
// /// Calls datasource → catches exceptions → returns Either<Failure, T>

// import 'dart:io';
// import 'package:dartz/dartz.dart';
// import '../../../../core/error/failures.dart';
// import '../../domain/entities/track_draft.dart';
// import '../../domain/repositories/upload_track_repository.dart';
// import '../datasources/upload_track_remote_datasource.dart';

// class UploadTrackRepositoryImpl implements UploadTrackRepository {
//   final UploadTrackRemoteDataSource dataSource;

//   const UploadTrackRepositoryImpl({required this.dataSource});

//   // ── Fetch Tags ─────────────────────────────────────────────────────

//   @override
//   Future<Either<Failure, List<String>>> fetchTags() async {
//     try {
//       final tags = await dataSource.fetchTags();
//       return Right(tags);
//     } on SocketException {
//       return const Left(NetworkFailure());
//     } catch (e) {
//       return Left(UnexpectedFailure(e.toString()));
//     }
//   }

//   // ── Upload Track ───────────────────────────────────────────────────

//   @override
//   Future<Either<Failure, String>> uploadTrack({
//     required TrackDraft draft,
//     required File audioFile,
//     File? artworkFile,
//     void Function(double progress)? onProgress,
//   }) async {
//     try {
//       final response = await dataSource.uploadTrack(
//         audioFile:   audioFile,
//         artworkFile: artworkFile,
//         title:       draft.title!,
//         artist:      draft.artist!,
//         genre:       draft.genre!,
//         description: draft.description,
//         caption:     draft.caption,
//         tags:        draft.tags,
//         isPublic:    draft.isPublic,
//         onProgress:  onProgress,
//       );

//       // Return just the id — all M13 needs
//       return Right(response.id);

//     } on SocketException {
//       return const Left(NetworkFailure());

//     // Each exception type → matching Failure type
//     } catch (e) {
//       final msg = e.toString();

//       if (msg.contains('401') || msg.contains('AuthException')) {
//         return const Left(AuthFailure());
//       }
//       if (msg.contains('403') || msg.contains('UploadLimit')) {
//         return const Left(UploadLimitFailure());
//       }
//       if (msg.contains('413') || msg.contains('FileTooLarge')) {
//         return const Left(FileTooLargeFailure());
//       }
//       if (msg.contains('415') || msg.contains('UnsupportedFile')) {
//         return const Left(UnsupportedFileFailure());
//       }
//       if (msg.contains('429') || msg.contains('RateLimit')) {
//         return const Left(ServerFailure('Too many requests. Please wait.'));
//       }

//       return Left(UploadFailure(msg));
//     }
//   }
// }