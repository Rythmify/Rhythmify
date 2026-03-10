import '../../domain/entities/track_summary.dart';

class TrackSummaryDto {
  static TrackSummary fromJson(Map<String, dynamic> json) {

    return TrackSummary(
      id:               json['id'] as String,
      artistId:         json['artist_id'] as String,
      title:            json['title'] as String,
      artist:           json['artist'] as String,
      artworkUrl:       json['artwork_url'] as String,
      audioUrl:         json['audio_url'] as String,
      shareUrl:         json['share_url'] as String,
      duration: Duration(seconds: json['duration_seconds'] as int),
      playCount:        json['play_count'] as int? ?? 0,
      isLiked:          json['is_liked'] as bool? ?? false,
      isArtistFollowed: json['is_artist_followed'] as bool? ?? false,
    );
  }

  static Map<String, dynamic> toJson(TrackSummary summary) {
    return {
      'id':                 summary.id,
      'artist_id':          summary.artistId,
      'title':              summary.title,
      'artist':             summary.artist,
      'artwork_url':        summary.artworkUrl,
      'audio_url':          summary.audioUrl,
      'share_url':          summary.shareUrl,
      'duration_seconds':   summary.duration.inSeconds,
      'play_count':         summary.playCount,
      'is_liked':           summary.isLiked,
      'is_artist_followed': summary.isArtistFollowed,
    };
  }
}