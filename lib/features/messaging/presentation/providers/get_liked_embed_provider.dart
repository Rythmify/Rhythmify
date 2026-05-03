import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rythmify/features/messaging/domain/entities/shared_embed.dart';
import 'package:rythmify/features/messaging/domain/usecases/get_liked_embeds_usecase.dart';
import 'package:rythmify/features/messaging/presentation/providers/current_user_id_provider.dart';
import 'package:rythmify/features/messaging/presentation/providers/repository_provider.dart';

/// A [FutureProvider] that fetches details of a playlist or album by its ID.
///
/// Takes a record of ([playlistId], [embedType]) as the family parameter.
/// [embedType] differentiates between `playlist` and `album` since both
/// use the same API endpoint.
/// Returns a [SharedEmbed] with name, artist, and thumbnail details.

final getLikedEmbedsProvider = FutureProvider.autoDispose
    .family<List<SharedEmbed>, String>((ref, embedType) async {
      final uCase = GetLikedEmbedsUseCase(repo: ref.read(repositoryprovider));
      final String userId = ref.watch(currentUserIdProvider);
      final msg = await uCase(userId, embedType);
      return msg;
    });
