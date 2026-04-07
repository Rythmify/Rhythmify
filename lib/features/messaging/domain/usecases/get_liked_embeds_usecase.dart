import 'package:rythmify/features/messaging/domain/entities/shared_embed.dart';
import 'package:rythmify/features/messaging/domain/repositories/messaging_repository.dart';

class GetLikedEmbedsUseCase {
  final MessagingRepository repo;

  GetLikedEmbedsUseCase({required this.repo});

  Future<List<SharedEmbed>> call(String userId, String embedType) async {
    return await repo.getLikedEmbeds(userId, embedType);
  }
}