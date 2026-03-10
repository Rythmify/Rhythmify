class TrackSummary {
  final String id;
  final String artistId;
  final String title;
  final String artist;
  final String artworkUrl;
  final String audioUrl;
  final Duration duration;
  final int playCount;
  final bool isLiked;
  final bool isArtistFollowed;

  const TrackSummary({
    required this.id,
    required this.artistId,
    required this.title,
    required this.artist,
    required this.artworkUrl,
    required this.audioUrl,
    required this.duration,
    required this.playCount,
    this.isLiked = false,
    this.isArtistFollowed = false,
  });
}