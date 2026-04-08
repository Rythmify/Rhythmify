import 'package:rythmify/features/messaging/domain/entities/shared_embed.dart';
import 'package:rythmify/features/messaging/domain/repositories/messaging_repository.dart';

/// Use case for retrieving details of a playlist or album by its ID.
///
/// Delegates to [MessagingRepository.getPlaylist].
/// [embedType] is passed through to differentiate between `playlist` and `album`
/// since both use the same API endpoint.
///
class GetPlaylistDetailsUsecase {
  final MessagingRepository repo;

  GetPlaylistDetailsUsecase({required this.repo});

  Future<SharedEmbed> call(String playlistId, String embedType) async {
    return await repo.getPlaylist(playlistId, embedType);
  }
}
