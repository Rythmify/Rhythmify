import '../../domain/entities/track.dart';

class TrackDto {
  static Track fromJson(Map<String, dynamic> json) {
    return Track(
      id:         json['id'] as String? ?? '',
      userId:     json['user_id'] as String? ?? json['artist_id'] as String? ?? '',
      title:      json['title'] as String? ?? '',
      artist:     json['artist'] as String? ?? json['user']?['display_name'] as String? ?? '',
      description: json['description'] as String?,
      coverImage:  json['cover_image'] as String? ?? json['artwork_url'] as String?,
      audioUrl:    json['audio_url'] as String? ?? json['stream_url'] as String? ?? '',
      streamUrl:   json['stream_url'] as String?,
      duration: Duration(seconds: json['duration'] as int? ?? json['duration_seconds'] as int? ?? 0),
      createdAt: DateTime.tryParse(json['created_at'] as String? ?? '') ?? DateTime.now(),
      updatedAt: json['updated_at'] != null ? DateTime.tryParse(json['updated_at'] as String) : null,
      
      playCount:     json['play_count'] as int? ?? 0,
      likeCount:     json['like_count'] as int? ?? 0,
      commentCount:  json['comment_count'] as int? ?? 0,
      repostCount:   json['repost_count'] as int? ?? 0,
      
      isLiked:          json['is_liked'] as bool? ?? false,
      isReposted:       json['is_reposted'] as bool? ?? false,
      isArtistFollowed: json['is_artist_followed'] as bool? ?? false,
      
      tags: (json['tags'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? const [],
      
      waveformData: json['waveform_data'] != null 
          ? List<double>.from(json['waveform_data'].map((x) => (x as num).toDouble())) 
          : null,
          
      genreId: json['genre_id'] as String?,
      isTrending: json['is_trending'] as bool? ?? false,
      isFeatured: json['is_featured'] as bool? ?? false,
      status: json['status'] as String?,
    );
  }

  static Map<String, dynamic> toJson(Track track) {
    return {
      'id':               track.id,
      'user_id':          track.userId,
      'title':            track.title,
      'artist':           track.artist,
      'description':      track.description,
      'cover_image':      track.coverImage,
      'audio_url':        track.audioUrl,
      'stream_url':       track.streamUrl,
      'duration':         track.duration.inSeconds,
      'created_at':       track.createdAt.toIso8601String(),
      'updated_at':       track.updatedAt?.toIso8601String(),
      
      'play_count':    track.playCount,
      'like_count':    track.likeCount,
      'comment_count': track.commentCount,
      'repost_count':  track.repostCount,
      
      'is_liked':           track.isLiked,
      'is_reposted':        track.isReposted,
      'is_artist_followed': track.isArtistFollowed,
      
      'tags':          track.tags,
      'waveform_data': track.waveformData,
      
      'genre_id':      track.genreId,
      'is_trending':   track.isTrending,
      'is_featured':   track.isFeatured,
      'status':        track.status,
    };
  }
}
