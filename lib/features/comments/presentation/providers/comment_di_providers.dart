import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasources/comment_local_datasource.dart';
import '../../data/repositories/mock_comment_repository_impl.dart';
import '../../domain/repositories/comment_repository.dart';
import '../../domain/usecases/delete_comment_usecase.dart';
import '../../domain/usecases/get_comment_replies_usecase.dart';
import '../../domain/usecases/get_floating_comments_usecase.dart';
import '../../domain/usecases/get_track_comments_usecase.dart';
import '../../domain/usecases/post_comment_usecase.dart';
import '../../domain/usecases/toggle_comment_like_usecase.dart';

/// ---------------------
/// DATA LAYER PROVIDERS
/// ---------------------

/// Provides the local data source (our mock JSON database).
final commentLocalDataSourceProvider = Provider<CommentLocalDataSource>((ref) {
  return MockCommentLocalDataSourceImpl();
});

/// Provides the concrete implementation of the repository, injecting the data source.
final commentRepositoryProvider = Provider<CommentRepository>((ref) {
  final dataSource = ref.watch(commentLocalDataSourceProvider);
  return MockCommentRepositoryImpl(dataSource);
});

/// -----------------------------------
/// DOMAIN LAYER PROVIDERS (USE CASES)
/// -----------------------------------

final getTrackCommentsProvider = Provider<GetTrackCommentsUseCase>((ref) {
  return GetTrackCommentsUseCase(ref.watch(commentRepositoryProvider));
});

final getCommentRepliesProvider = Provider<GetCommentRepliesUseCase>((ref) {
  return GetCommentRepliesUseCase(ref.watch(commentRepositoryProvider));
});

final getFloatingCommentsProvider = Provider<GetFloatingCommentsUseCase>((ref) {
  return GetFloatingCommentsUseCase(ref.watch(commentRepositoryProvider));
});

final postCommentProvider = Provider<PostCommentUseCase>((ref) {
  return PostCommentUseCase(ref.watch(commentRepositoryProvider));
});

final toggleCommentLikeProvider = Provider<ToggleCommentLikeUseCase>((ref) {
  return ToggleCommentLikeUseCase(ref.watch(commentRepositoryProvider));
});

final deleteCommentProvider = Provider<DeleteCommentUseCase>((ref) {
  return DeleteCommentUseCase(ref.watch(commentRepositoryProvider));
});