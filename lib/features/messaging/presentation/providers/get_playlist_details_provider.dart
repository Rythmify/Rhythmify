import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rythmify/features/messaging/domain/entities/shared_embed.dart';
import 'package:rythmify/features/messaging/domain/usecases/get_playlist_details_usecase.dart';
import 'package:rythmify/features/messaging/presentation/providers/repository_provider.dart';

/// A [FutureProvider] that fetches details of a playlist or album by its ID.
///
/// Takes a record of ([playlistId], [embedType]) as the family parameter.
/// [embedType] differentiates between `playlist` and `album` since both
/// use the same API endpoint.
/// Returns a [SharedEmbed] with name, artist, and thumbnail details.

final getPlaylistDetailsProvider =
    FutureProvider.family<SharedEmbed, (String, String)>((ref, args) async {
      final playlistId = args.$1; //Id of playlist or Album
      final embedType = args.$2;
      final uCase = GetPlaylistDetailsUsecase(
        repo: ref.read(repositoryprovider),
      );
      final msg = await uCase(playlistId, embedType);
      return msg;
    });
