import '../repositories/comment_repository.dart';

/// A Domain layer UseCase to fetch floating comments for a track.
///
/// These floating comments are highly optimized data points intended to be
/// displayed synchronously alongside audio waveform rendering.
class GetFloatingCommentsUseCase {
  final CommentRepository repository;

  /// Creates a [GetFloatingCommentsUseCase] with the provided [repository].
  GetFloatingCommentsUseCase(this.repository);

  /// Executes the use case to fetch floating comments for [trackId].
  ///
  /// This should be called once when the track begins loading or playing.
  /// Returns a highly optimized [Future] resolving to a `Map<int, ({String? pfp, String text})>`
  /// representing the track timestamp mapped to a record containing the user's
  /// profile picture URL and comment text, enabling O(1) lookups.
  Future<Map<int, ({String? pfp, String text})>> call(String trackId) {
    return repository.getFloatingComments(trackId);
  }
}
