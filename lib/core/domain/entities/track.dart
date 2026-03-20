class Track {
  final String id;
  final String userId;
  final String title;
  final String artist;
  final String? description;   // "Heavy" data (Nullable)
  final String? coverImage;
  final String audioUrl;
  final String? streamUrl;
  final String? waveformUrl;
  final Duration duration;

  final int playCount;
  final int likeCount;
  final int commentCount;
  final int repostCount;
  
  final bool isLiked;
  final bool isReposted;
  final bool isArtistFollowed;
  final List<String> tags;
  
  final List<double>? waveformData;   // "Heavy" data (Nullable)

  final String? genre;
  final String? artists;
  final String? recordLabel;
  final String? releaseDate;
  final bool explicitContent;

  final bool isTrending;
  final bool isFeatured;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final String? status;

  const Track({
    required this.id,
    required this.userId,
    required this.title,
    required this.artist,
    required this.audioUrl,
    required this.duration,
    required this.createdAt,
    this.description,
    this.coverImage,
    this.streamUrl,
    this.waveformUrl,
    this.playCount = 0,
    this.likeCount = 0,
    this.commentCount = 0,
    this.repostCount = 0,
    this.isLiked = false,
    this.isReposted = false,
    this.isArtistFollowed = false,
    this.tags = const [],
    this.waveformData,
    this.genre,
    this.artists,
    this.recordLabel,
    this.releaseDate,
    this.explicitContent = false,
    this.isTrending = false,
    this.isFeatured = false,
    this.updatedAt,
    this.status,
  });

  // Compatibility with older artworkUrl field
  String get artworkUrl => coverImage ?? '';

  Track copyWith({
    String? id,
    String? userId,
    String? title,
    String? artist,
    String? description,
    String? coverImage,
    String? audioUrl,
    String? streamUrl,
    String? waveformUrl,
    Duration? duration,
    int? playCount,
    int? likeCount,
    int? commentCount,
    int? repostCount,
    bool? isLiked,
    bool? isReposted,
    bool? isArtistFollowed,
    List<String>? tags,
    List<double>? waveformData,
    String? genre,
    String? artists,
    String? recordLabel,
    String? releaseDate,
    bool? explicitContent,
    bool? isTrending,
    bool? isFeatured,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? status,
  }) {
    return Track(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      artist: artist ?? this.artist,
      description: description ?? this.description,
      coverImage: coverImage ?? this.coverImage,
      audioUrl: audioUrl ?? this.audioUrl,
      streamUrl: streamUrl ?? this.streamUrl,
      waveformUrl: waveformUrl ?? this.waveformUrl,
      duration: duration ?? this.duration,
      playCount: playCount ?? this.playCount,
      likeCount: likeCount ?? this.likeCount,
      commentCount: commentCount ?? this.commentCount,
      repostCount: repostCount ?? this.repostCount,
      isLiked: isLiked ?? this.isLiked,
      isReposted: isReposted ?? this.isReposted,
      isArtistFollowed: isArtistFollowed ?? this.isArtistFollowed,
      tags: tags ?? this.tags,
      waveformData: waveformData ?? this.waveformData,
      genre: genre ?? this.genre,
      artists: artists ?? this.artists,
      recordLabel: recordLabel ?? this.recordLabel,
      releaseDate: releaseDate ?? this.releaseDate,
      explicitContent: explicitContent ?? this.explicitContent,
      isTrending: isTrending ?? this.isTrending,
      isFeatured: isFeatured ?? this.isFeatured,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      status: status ?? this.status,
    );
  }
}
