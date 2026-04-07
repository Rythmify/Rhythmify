import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rythmify/features/messaging/domain/entities/shared_embed.dart';
import 'package:rythmify/features/messaging/domain/usecases/get_playlist_details_usecase.dart';
import 'package:rythmify/features/messaging/presentation/providers/repository_provider.dart';

final getPlaylistDetailsProvider = FutureProvider.family<SharedEmbed, (String,String)>
((ref,args) async {
  final playlistId=args.$1; //Id of playlist or Album
  final embedType=args.$2;
  final uCase = GetPlaylistDetailsUsecase(repo: ref.read(repositoryprovider));
  final msg = await uCase(playlistId,embedType);
  return msg;
});