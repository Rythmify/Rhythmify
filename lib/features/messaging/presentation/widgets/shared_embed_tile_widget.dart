import 'package:flutter/material.dart';
import 'package:rythmify/features/messaging/domain/entities/shared_embed.dart';

/// A list tile widget representing a single [SharedEmbed] (track, playlist, or album).
///
/// Displays the embed thumbnail, name, and artist name with a circular
/// selection indicator on the trailing end. Highlights the tile background
/// when [isSelected] is true.
///
/// Used in [LikesPlaylistsScreen] to allow users to select embeds to share.

class SharedEmbedTileWidget extends StatelessWidget {
  final SharedEmbed embed;
  final bool isSelected;
  final VoidCallback onTap;

  const SharedEmbedTileWidget({
    super.key,
    required this.embed,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(
        splashFactory: InkRipple.splashFactory,
        splashColor: const Color(0xFF2F2F2F),
        highlightColor: Colors.transparent,
        colorScheme: Theme.of(context).colorScheme.copyWith(
          primary: Colors.white, // this stops the orange from bleeding in
        ),
      ),
      child: ListTile(
        onTap: onTap,
        tileColor: isSelected ? const Color(0xFF2F2F2F) : Colors.transparent,
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: (embed.thumbnailUrl != null && embed.thumbnailUrl!.isNotEmpty)
              ? Image.network(
                  embed.thumbnailUrl!,
                  width: 48,
                  height: 48,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    width: 48,
                    height: 48,
                    color: const Color(0xFF2F2F2F),
                    child: embed.embedType == 'track'
                        ? const Icon(Icons.music_note, color: Colors.white54)
                        : const Icon(Icons.queue_music, color: Colors.white54),
                  ),
                )
              : Container(
                  width: 48,
                  height: 48,
                  color: const Color(0xFF2F2F2F),
                  child: embed.embedType == 'track'
                      ? const Icon(Icons.music_note, color: Colors.white54)
                      : const Icon(Icons.queue_music, color: Colors.white54),
                ),
        ),
        title: Text(
          embed.embedName,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(
          embed.artistName ?? '',
          style: const TextStyle(color: Colors.white70, fontSize: 13),
        ),
        trailing: Container(
          width: 22,
          height: 22,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: isSelected
                ? Border.all(color: Colors.white, width: 1.5)
                : Border.all(color: Colors.grey, width: 1.5),
            color: isSelected ? Colors.white : Colors.transparent,
          ),
          child: isSelected
              ? const Icon(Icons.check, size: 14, color: Colors.black)
              : null,
        ),
      ),
    );
  }
}
