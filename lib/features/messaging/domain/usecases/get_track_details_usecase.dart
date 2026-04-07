import 'package:rythmify/features/messaging/domain/entities/shared_embed.dart';
import 'package:rythmify/features/messaging/domain/repositories/messaging_repository.dart';

class GetTrackDetailsUsecase {
  final MessagingRepository repo;

  GetTrackDetailsUsecase({required this.repo});

  Future<SharedEmbed> call(String trackId) async {
    return repo.getTrack(trackId);
  }
}