import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rythmify/features/messaging/domain/entities/shared_embed.dart';
import 'package:rythmify/features/messaging/domain/usecases/get_liked_embeds_usecase.dart';
import 'package:rythmify/features/messaging/presentation/providers/current_user_id_provider.dart';
import 'package:rythmify/features/messaging/presentation/providers/repository_provider.dart';

final getLikedEmbedsProvider = FutureProvider.family<List<SharedEmbed>, String>((
  ref,
  embedType,
) async {
  final uCase = GetLikedEmbedsUseCase(repo: ref.read(repositoryprovider));
  final String userId = ref.watch(currentUserIdProvider);
  final msg = await uCase(userId, embedType);
  return msg;
});