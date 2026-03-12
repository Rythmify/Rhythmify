import '../../domain/entities/track.dart';

class TrackDto {
  static Track fromJson(Map<String, dynamic> json) {
    return Track(
      id:         json['id'] as String,
      artistId:   json['artist_id'] as String,
      title:      json['title'] as String,
      artist:     json['artist'] as String,
      artworkUrl: json['artwork_url'] as String,
      audioUrl:   json['audio_url'] as String,
      shareUrl:   json['share_url'] as String? ?? '',
      duration: Duration(seconds: json['duration_seconds'] as int),
      createdAt: DateTime.tryParse(json['created_at'] as String? ?? '') ?? DateTime.now(),
      
      playCount:     json['play_count'] as int? ?? 0,
      likeCount:     json['like_count'] as int? ?? 0,
      repostCount:   json['repost_count'] as int? ?? 0,
      commentCount:  json['comment_count'] as int? ?? 0,
      
      isLiked:          json['is_liked'] as bool? ?? false,
      isReposted:       json['is_reposted'] as bool? ?? false,
      isArtistFollowed: json['is_artist_followed'] as bool? ?? false,
      tags: (json['tags'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? const [],
      description: json['description'] as String?,
      
      // Safely Converting any ints to doubles
      waveformData: json['waveform_data'] != null 
          ? List<double>.from(json['waveform_data'].map((x) => (x as num).toDouble())) 
          : null,
    );
  }

  static Map<String, dynamic> toJson(Track track) {
    return {
      'id':               track.id,
      'artist_id':        track.artistId,
      'title':            track.title,
      'artist':           track.artist,
      'artwork_url':      track.artworkUrl,
      'audio_url':        track.audioUrl,
      'share_url':        track.shareUrl,
      'duration_seconds': track.duration.inSeconds,
      'created_at':       track.createdAt.toIso8601String(),
      
      'play_count':    track.playCount,
      'like_count':    track.likeCount,
      'repost_count':  track.repostCount,
      'comment_count': track.commentCount,
      
      'is_liked':           track.isLiked,
      'is_reposted':        track.isReposted,
      'is_artist_followed': track.isArtistFollowed,
      'tags':          track.tags,
      'description':   track.description,
      'waveform_data': track.waveformData,
    };
  }
}