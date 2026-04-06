import 'package:flutter_riverpod/flutter_riverpod.dart';

// --- Core / Network ---
import '../../../../core/network/api_client.dart'; // Adjust this path if needed

// --- Data Sources ---
import '../../data/datasources/comment_local_datasource.dart';
import '../../data/datasources/comment_remote_datasource.dart'; // NEW

// --- Repositories ---
import '../../data/repositories/mock_comment_repository_impl.dart';
import '../../data/repositories/comment_remote_repository_impl.dart'; // NEW

// --- Domain ---
import '../../domain/repositories/comment_repository.dart';
import '../../domain/usecases/delete_comment_usecase.dart';
import '../../domain/usecases/get_comment_replies_usecase.dart';
import '../../domain/usecases/get_floating_comments_usecase.dart';
import '../../domain/usecases/get_track_comments_usecase.dart';
import '../../domain/usecases/post_comment_usecase.dart';
import '../../domain/usecases/toggle_comment_like_usecase.dart';

/// ==========================================
/// THE ENVIRONMENT SWITCH
/// Set to true to use local JSON mock data.
/// Set to false to hit the real Rythmify API.
/// ==========================================
const bool useMockCommentsData = true;

/// ---------------------
/// CORE PROVIDERS
/// ---------------------

/// Provides the ApiClient needed for remote calls.
final apiClientProvider = Provider<ApiClient>((ref) {
  return apiClient; // Assuming 'apiClient' is your global instance from earlier
});

/// ---------------------
/// DATA SOURCE PROVIDERS
/// ---------------------

/// Provides the local data source (our mock JSON database).
final commentLocalDataSourceProvider = Provider<CommentLocalDataSource>((ref) {
  return MockCommentLocalDataSourceImpl();
});

/// Provides the remote data source (real backend).
final commentRemoteDataSourceProvider = Provider<CommentRemoteDataSource>((
  ref,
) {
  final client = ref.watch(apiClientProvider);
  return CommentRemoteDataSourceImpl(client);
});

/// ---------------------
/// REPOSITORY PROVIDER
/// ---------------------

/// Provides the concrete implementation of the repository based on the boolean switch.
final commentRepositoryProvider = Provider<CommentRepository>((ref) {
  if (useMockCommentsData) {
    // Uses the Mock implementation
    final localDataSource = ref.watch(commentLocalDataSourceProvider);
    return MockCommentRepositoryImpl(localDataSource);
  } else {
    // Uses the Real implementation
    final remoteDataSource = ref.watch(commentRemoteDataSourceProvider);
    return CommentRemoteRepositoryImpl(remoteDataSource);
  }
});

/// -----------------------------------
/// DOMAIN LAYER PROVIDERS (USE CASES)
/// -----------------------------------
/// These stay EXACTLY the same! They only know about the abstract 'CommentRepository',
/// so they don't care if the data comes from the JSON file or the Azure backend.

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
