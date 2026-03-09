class Track {
  final String id;
  final String title;
  final String artist;
  final String artworkUrl;
  final String audioUrl;
  final String shareUrl;
  final Duration duration;
  final DateTime createdAt;

  final int playCount;
  final int likeCount;
  final int repostCount;
  final int commentCount;

  final bool isLiked;
  final bool isReposted;
  final List<String> tags;
  final String? description;          // Nullable (no need in home page or similar pages)
  final List<double>? waveformData;   // Nullable (no need in home page or similar pages)

  const Track({
    required this.id,
    required this.title,
    required this.artist,
    required this.artworkUrl,
    required this.audioUrl,
    required this.shareUrl,
    required this.duration,
    required this.createdAt,
    this.playCount = 0,
    this.likeCount = 0,
    this.repostCount = 0,
    this.commentCount = 0,
    this.isLiked = false,
    this.isReposted = false,
    this.tags = const [],
    this.description,
    this.waveformData,
  });

  Track copyWith({
    String? id,
    String? title,
    String? artist,
    String? artworkUrl,
    String? audioUrl,
    String? shareUrl,
    Duration? duration,
    DateTime? createdAt,
    int? playCount,
    int? likeCount,
    int? repostCount,
    int? commentCount,
    bool? isLiked,
    bool? isReposted,
    List<String>? tags,
    String? description,
    List<double>? waveformData,
  }) {
    return Track(
      id: id ?? this.id,
      title: title ?? this.title,
      artist: artist ?? this.artist,
      artworkUrl: artworkUrl ?? this.artworkUrl,
      audioUrl: audioUrl ?? this.audioUrl,
      shareUrl: shareUrl ?? this.shareUrl,
      duration: duration ?? this.duration,
      createdAt: createdAt ?? this.createdAt,
      playCount: playCount ?? this.playCount,
      likeCount: likeCount ?? this.likeCount,
      repostCount: repostCount ?? this.repostCount,
      commentCount: commentCount ?? this.commentCount,
      isLiked: isLiked ?? this.isLiked,
      isReposted: isReposted ?? this.isReposted,
      tags: tags ?? this.tags,
      description: description ?? this.description,
      waveformData: waveformData ?? this.waveformData,
    );
  }
}