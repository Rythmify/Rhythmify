class Track {
  final String id;
  final String userId;       // Matches "user_id" in DB
  final String title;
  final String artist;       // Display name of the user/artist
  final String? description; // Nullable (Heavy)
  final String? coverImage;  // Matches "cover_image"
  final String audioUrl;
  final String? streamUrl;
  final Duration duration;
  final int playCount;
  final int likeCount;
  final int commentCount;
  final int repostCount;
  
  // UI/State specific fields (usually from joins/logic)
  final bool isLiked;
  final bool isReposted;
  final bool isArtistFollowed;
  final List<String> tags;   // From "track_tags" join
  
  // "Heavy" data (Nullable)
  final List<double>? waveformData; 

  // New fields from your DB schema
  final String? genreId;
  final bool isTrending;
  final bool isFeatured;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final String? status; // track_status enum in DB

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
    this.playCount = 0,
    this.likeCount = 0,
    this.commentCount = 0,
    this.repostCount = 0,
    this.isLiked = false,
    this.isReposted = false,
    this.isArtistFollowed = false,
    this.tags = const [],
    this.waveformData,
    this.genreId,
    this.isTrending = false,
    this.isFeatured = false,
    this.updatedAt,
    this.status,
  });

  // Backward compatibility with older artworkUrl field
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
    String? genreId,
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
      genreId: genreId ?? this.genreId,
      isTrending: isTrending ?? this.isTrending,
      isFeatured: isFeatured ?? this.isFeatured,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      status: status ?? this.status,
    );
  }
}
