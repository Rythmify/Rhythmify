import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rythmify/features/messaging/domain/entities/shared_embed.dart';
import 'package:rythmify/features/messaging/presentation/providers/get_playlist_details_provider.dart';
import 'package:rythmify/features/messaging/presentation/providers/get_track_details_provider.dart';
import 'package:rythmify/features/messaging/presentation/widgets/avatar.dart';

class MessageBubble extends ConsumerWidget {
  final String senderId;
  final String? body;
  final String myId;
  final String? embedId;
  final String? embedType;
  final String? userAvatar;
  final BorderRadius borderRadius;

  const MessageBubble({
    super.key,
    required this.myId,
    this.body,
    this.embedId,
    this.embedType,
    required this.senderId,
    this.userAvatar,
    required this.borderRadius,
  });

  bool get isMe => (senderId == myId);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    SharedEmbed? embedDetails;

    if(embedId!=null && embedType!=null)
    {
      if(embedType=='track')
      {
        embedDetails=ref.watch(getTrackDetailsProvider(embedId!)).value;
      } else {
        embedDetails=ref.watch(getPlaylistDetailsProvider((embedId!,embedType!))).value;
      }
    }

    return Padding(
      padding: EdgeInsets.only(bottom: 0),
      child: 
          Row(
            mainAxisAlignment: isMe
                ? MainAxisAlignment.end
                : MainAxisAlignment.start,
            children: [
              if (!isMe) ...[
                Avatar(img: userAvatar, radius: 18),
                const SizedBox(width: 10),
              ],
              Flexible(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: MediaQuery.of(context).size.width * 0.6,
                    minWidth: MediaQuery.of(context).size.width * 0.6,
                  ),
                  child: Container(
                    padding: body == null && embedType != null
                          ? EdgeInsets.zero
                          : const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2F2F31),
                      borderRadius: borderRadius,
                    ),
                    child: Column(
                      crossAxisAlignment:CrossAxisAlignment.start,
                      children:[
                        if (embedType == 'track' || embedType == 'playlist' || embedType == 'album') ...[
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFF2F2F31),
                            borderRadius: borderRadius,
                          ),
                          child: Row(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(4),
                                child: embedDetails?.thumbnailUrl != null
                                    ? Image.network(
                                        embedDetails!.thumbnailUrl!,
                                        width: 56, height: 56,
                                        fit: BoxFit.cover,
                                      )
                                    : Container(
                                        width: 56, height: 56,
                                        color: const Color(0xFF3A3A3A),
                                        child: Icon(
                                          embedType == 'track'
                                              ? Icons.music_note
                                              : Icons.queue_music,
                                          color: Colors.white,
                                          size: 28,
                                        ),
                                      ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                  Text(
                                    embedDetails?.embedName ?? 
                                      (embedType == 'track' 
                                        ? 'Shared a track' 
                                        : embedType == 'playlist' 
                                          ? 'Shared a playlist' 
                                          : 'Shared an album'),
                                    style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w700),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  if (embedDetails?.artistName != null)
                                    Text(
                                      embedDetails!.artistName!,
                                      style: const TextStyle(color: Colors.grey, fontSize: 13),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (body != null) const SizedBox(height: 8),
                      ],
                    if (body != null)
                      Text(
                        body!,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                        ),
                      ),
                      ]
                    )
                  ),
                ),
              ),
            ],
          )
      );
  }
}
