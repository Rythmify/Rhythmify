import '../repositories/comment_repository.dart';

/// Executes the use case.
///
/// This should be called once when the track begins loading/playing.
/// Returns a highly optimized `Map<int, String>` for O(1) lookups.

class GetFloatingCommentsUseCase {
  final CommentRepository repository;

  GetFloatingCommentsUseCase(this.repository);

  // CHANGED: Return type is now the Record Map
  Future<Map<int, ({String? pfp, String text})>> call(String trackId) {
    return repository.getFloatingComments(trackId);
  }
}
