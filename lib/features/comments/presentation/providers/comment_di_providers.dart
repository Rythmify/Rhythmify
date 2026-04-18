import 'package:flutter_riverpod/flutter_riverpod.dart';

// --- Core / Network ---
import '../../../../core/network/api_client.dart'; // Adjust this path if needed

// --- Data Sources ---
import '../../data/datasources/comment_local_datasource.dart';
import '../../data/datasources/comment_remote_datasource.dart';

// --- Repositories ---
import '../../data/repositories/mock_comment_repository_impl.dart';
import '../../data/repositories/comment_remote_repository_impl.dart';

// --- Domain ---
import '../../domain/repositories/comment_repository.dart';
import '../../domain/usecases/delete_comment_usecase.dart';
import '../../domain/usecases/get_comment_replies_usecase.dart';
import '../../domain/usecases/get_replies_usecase.dart';
import '../../domain/usecases/get_floating_comments_usecase.dart';
import '../../domain/usecases/get_track_comments_usecase.dart';
import '../../domain/usecases/post_comment_usecase.dart';
import '../../domain/usecases/post_reply_usecase.dart';
import '../../domain/usecases/toggle_comment_like_usecase.dart';
import '../../domain/usecases/unblock_user_usecase.dart';
import '../../domain/usecases/block_user_usecase.dart';

// ================================
//  --- THE ENVIRONMENT SWITCH ---
// ================================

/// Switch to determine whether to use the mock JSON data or the real backend.
const bool useMockCommentsData = false;

/// ---------------------
/// CORE PROVIDERS
/// ---------------------

/// Provides the [ApiClient] needed for remote calls.
final apiClientProvider = Provider<ApiClient>((ref) {
  return apiClient;
});

/// ---------------------
/// DATA SOURCE PROVIDERS
/// ---------------------

/// Provides the local data source which simulates a JSON database.
final commentLocalDataSourceProvider = Provider<CommentLocalDataSource>((ref) {
  return MockCommentLocalDataSourceImpl();
});

/// Provides the remote data source connecting to the real backend.
final commentRemoteDataSourceProvider = Provider<CommentRemoteDataSource>((
  ref,
) {
  final client = ref.watch(apiClientProvider);
  return CommentRemoteDataSourceImpl(client);
});

/// ---------------------
/// REPOSITORY PROVIDER
/// ---------------------

/// Provides the concrete implementation of the repository based on the environment switch.
final commentRepositoryProvider = Provider<CommentRepository>((ref) {
  if (useMockCommentsData) {
    final localDataSource = ref.watch(commentLocalDataSourceProvider);
    return MockCommentRepositoryImpl(localDataSource);
  } else {
    final remoteDataSource = ref.watch(commentRemoteDataSourceProvider);
    return CommentRemoteRepositoryImpl(remoteDataSource);
  }
});

/// -----------------------------------
/// DOMAIN LAYER PROVIDERS (USE CASES)
/// -----------------------------------

/// Provides the [GetTrackCommentsUseCase].
final getTrackCommentsProvider = Provider<GetTrackCommentsUseCase>((ref) {
  return GetTrackCommentsUseCase(ref.watch(commentRepositoryProvider));
});

/// Provides the [GetCommentRepliesUseCase].
final getCommentRepliesProvider = Provider<GetCommentRepliesUseCase>((ref) {
  return GetCommentRepliesUseCase(ref.watch(commentRepositoryProvider));
});

/// Provides the [GetRepliesUseCase].
final getRepliesProvider = Provider<GetRepliesUseCase>((ref) {
  return GetRepliesUseCase(ref.watch(commentRepositoryProvider));
});

/// Provides the [GetFloatingCommentsUseCase].
final getFloatingCommentsProvider = Provider<GetFloatingCommentsUseCase>((ref) {
  return GetFloatingCommentsUseCase(ref.watch(commentRepositoryProvider));
});

/// Provides the [PostCommentUseCase].
final postCommentProvider = Provider<PostCommentUseCase>((ref) {
  return PostCommentUseCase(ref.watch(commentRepositoryProvider));
});

/// Provides the [PostReplyUseCase].
final postReplyProvider = Provider<PostReplyUseCase>((ref) {
  return PostReplyUseCase(ref.watch(commentRepositoryProvider));
});

/// Provides the [ToggleCommentLikeUseCase].
final toggleCommentLikeProvider = Provider<ToggleCommentLikeUseCase>((ref) {
  return ToggleCommentLikeUseCase(ref.watch(commentRepositoryProvider));
});

/// Provides the [DeleteCommentUseCase].
final deleteCommentProvider = Provider<DeleteCommentUseCase>((ref) {
  return DeleteCommentUseCase(ref.watch(commentRepositoryProvider));
});

/// Provides the [BlockUserUseCase].
final blockUserProvider = Provider<BlockUserUseCase>((ref) {
  return BlockUserUseCase(ref.watch(commentRepositoryProvider));
});

/// Provides the [UnblockUserUseCase].
final unblockUserProvider = Provider<UnblockUserUseCase>((ref) {
  return UnblockUserUseCase(ref.watch(commentRepositoryProvider));
});
