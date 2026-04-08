import 'package:rythmify/features/messaging/domain/entities/shared_embed.dart';
import 'package:rythmify/features/messaging/domain/repositories/messaging_repository.dart';

/// Use case for retrieving liked embeds (tracks, playlists, or albums) for a user.
///
/// Delegates to [MessagingRepository.getLikedEmbeds] filtered by [embedType].
/// Used in [getLikedEmbedsProvider] to populate [LikesPlaylistsScreen] tabs.
class GetLikedEmbedsUseCase {
  final MessagingRepository repo;

  GetLikedEmbedsUseCase({required this.repo});

  Future<List<SharedEmbed>> call(String userId, String embedType) async {
    return await repo.getLikedEmbeds(userId, embedType);
  }
}
