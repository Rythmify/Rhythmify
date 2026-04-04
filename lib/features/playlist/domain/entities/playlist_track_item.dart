/// Domain entity for a single track entry inside a playlist.
///
/// Sourced from `GET /playlists/{id}/tracks`.
/// Maps the `PlaylistTrackListItem` API schema — includes position ordering,
/// the track's display metadata, and soft-delete awareness via [deletedAt].
///
/// This is not a full [Track] — it only carries the fields needed to render
/// a row in [PlaylistDetailScreen] without a second network call.
class PlaylistTrackItem {
  const PlaylistTrackItem({
    required this.trackId,
    required this.position,
    required this.addedAt,
    required this.title,
    required this.artistName,
    required this.artistId,
    required this.isPublic,
    this.duration,
    this.coverImageUrl,
    this.deletedAt,
  });

  /// The track's UUID — used to navigate to the track detail page.
  final String trackId;

  /// 1-based ordering index within the playlist.
  final int position;

  final DateTime addedAt;
  final String title;
  final String artistName;
  final String artistId;
  final bool isPublic;

  /// Duration in seconds. Null if track is still processing.
  final int? duration;

  final String? coverImageUrl;

  /// Non-null when the track has been deleted by its owner but is still
  /// referenced in the playlist. The UI should render a "deleted" state.
  final DateTime? deletedAt;

  bool get isDeleted => deletedAt != null;

  /// Formats [duration] as `m:ss` (e.g. `3:47`). Returns `--:--` if null.
  String get formattedDuration {
    if (duration == null) return '--:--';
    final minutes = duration! ~/ 60;
    final seconds = (duration! % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  PlaylistTrackItem copyWith({
    int? position,
  }) {
    return PlaylistTrackItem(
      trackId: trackId,
      position: position ?? this.position,
      addedAt: addedAt,
      title: title,
      artistName: artistName,
      artistId: artistId,
      isPublic: isPublic,
      duration: duration,
      coverImageUrl: coverImageUrl,
      deletedAt: deletedAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PlaylistTrackItem &&
          runtimeType == other.runtimeType &&
          trackId == other.trackId;

  @override
  int get hashCode => trackId.hashCode;
}