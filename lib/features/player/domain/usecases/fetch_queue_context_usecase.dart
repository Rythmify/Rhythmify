import '../repositories/playback_repository.dart';

class FetchQueueContextUseCase {
  final PlaybackRepository repository;

  FetchQueueContextUseCase(this.repository);

  Future<Map<String, dynamic>> call({
    required String interactionType,
    required String sourceType,
    String? sourceId,
    String? targetUserId,
  }) async {
    return await repository.fetchQueueContext(
      interactionType: interactionType,
      sourceType: sourceType,
      sourceId: sourceId,
      targetUserId: targetUserId,
    );
  }
}
