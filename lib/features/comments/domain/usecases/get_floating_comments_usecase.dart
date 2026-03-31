import '../repositories/comment_repository.dart';

/// Use case to retrieve lightweight timestamp-to-avatar mappings for the waveform.
class GetFloatingCommentsUseCase {
  final CommentRepository _repository;

  GetFloatingCommentsUseCase(this._repository);

  /// Executes the use case.
  /// 
  /// This should be called once when the track begins loading/playing.
  /// Returns a highly optimized `Map<int, String>` for O(1) lookups.
  Future<Map<int, String>> call(String trackId) {
    return _repository.getFloatingComments(trackId);
  }
}