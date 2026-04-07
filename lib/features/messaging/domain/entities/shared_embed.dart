/// Entity representing a shared embed (track, playlist, or album).
///
/// Used across the messaging feature to represent embeds selected by the user
/// in [LikesPlaylistsScreen] and displayed in [MessageBubble].
///
/// [embedId] — unique identifier of the resource.
/// [embedType] — one of `track`, `playlist`, or `album`.
/// [embedName] — display name (track title or playlist name).
/// [artistName] — optional artist or owner name.
/// [thumbnailUrl] — optional URL for the cover image.
class SharedEmbed {
  final String embedId;
  final String embedType;
  final String embedName;
  final String? artistName;
  final String? thumbnailUrl;

  SharedEmbed({
    required this.embedId,
    required this.embedType,
    required this.embedName,
    this.artistName,
    this.thumbnailUrl,
  });
}
