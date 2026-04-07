import 'package:rythmify/features/messaging/domain/entities/shared_embed.dart';
import 'package:rythmify/features/messaging/domain/repositories/messaging_repository.dart';

class GetPlaylistDetailsUsecase {
  final MessagingRepository repo;

  GetPlaylistDetailsUsecase({required this.repo});

  Future<SharedEmbed> call(String playlistId, String embedType) async {
    return await repo.getPlaylist(playlistId, embedType);
  }
}