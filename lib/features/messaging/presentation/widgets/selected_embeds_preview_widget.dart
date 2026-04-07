import 'package:flutter/material.dart';
import 'package:rythmify/features/messaging/domain/entities/shared_embed.dart';

/// A horizontally scrollable preview of selected embeds (tracks, playlists, albums)
/// shown above the message input before sending.
///
/// Each card displays the embed thumbnail, name, and artist name with an [X]
/// button to remove it from the selection. Returns [SizedBox.shrink] when
/// [selectedEmbeds] is empty.
///
/// Requires [selectedEmbeds] — the list of currently selected [SharedEmbed] objects,
/// and [onRemove] — a callback that receives the index of the removed embed.
class SelectedEmbedsPreviewWidget extends StatelessWidget {
  final List<SharedEmbed> selectedEmbeds;
  final void Function(int) onRemove;

  const SelectedEmbedsPreviewWidget({
    super.key,
    required this.selectedEmbeds,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    if (selectedEmbeds.isEmpty) return const SizedBox.shrink();
    return Container(
      height: 90,
      color: Colors.transparent,
      child: ListView.builder(
        itemCount: selectedEmbeds.length,
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        itemBuilder: (context, index) {
          final embeds = selectedEmbeds[index];
          return Container(
            margin: const EdgeInsets.only(right: 8),
            width: MediaQuery.of(context).size.width * 0.85,
            decoration: BoxDecoration(
              color: const Color(0xFF2F2F31),
              borderRadius: BorderRadius.zero,
            ),

            child: IntrinsicHeight(
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(8),
                      bottomLeft: Radius.circular(8),
                    ),
                    child: embeds.thumbnailUrl != null
                        ? Image.network(
                            embeds.thumbnailUrl!,
                            width: 65,
                            height: 80,
                            fit: BoxFit.cover,
                          )
                        : Container(
                            width: 65,
                            height: 80,
                            color: Color(0xFF3A3A3A),
                            child: embeds.embedType == 'track'
                                ? Icon(Icons.music_note, color: Colors.white54)
                                : Icon(
                                    Icons.queue_music,
                                    color: Colors.white54,
                                  ),
                          ),
                  ),
                  //const SizedBox(width: 8),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            embeds.embedName,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: 15,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          if (embeds.artistName != null)
                            Text(
                              embeds.artistName!,
                              style: const TextStyle(
                                color: Colors.grey,
                                fontSize: 13,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                        ],
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => onRemove(index),
                    icon: const Icon(
                      Icons.close,
                      size: 16,
                      color: Colors.white54,
                    ),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                  const SizedBox(width: 4),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
