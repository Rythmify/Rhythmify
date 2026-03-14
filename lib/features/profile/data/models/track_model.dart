import '../../../../core/domain/entities/track_summary.dart';

class TrackModel extends TrackSummary {
  const TrackModel({
    required super.id,
    required super.artistId,
    required super.title,
    required super.artist,
    required super.artworkUrl,
    required super.audioUrl,
    required super.shareUrl,
    required super.duration,
    required super.playCount,
    super.isLiked,
    super.isArtistFollowed,
  });

  factory TrackModel.fromJson(Map<String, dynamic> json) {
    return TrackModel(
      id: json['id'] as String? ?? '',
      artistId: json['user']?['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      artist: json['user']?['display_name'] as String? ?? '',
      artworkUrl: json['artwork_url'] as String? ?? '',
      audioUrl: json['stream_url'] as String? ?? '',
      shareUrl: json['permalink_url'] as String? ?? '',
      duration: Duration(
        seconds: json['duration'] as int? ?? 0,
      ),
      playCount: json['play_count'] as int? ?? 0,
      isLiked: json['is_liked'] as bool? ?? false,
      isArtistFollowed: json['is_artist_followed'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'artist_id': artistId,
      'title': title,
      'artist': artist,
      'artwork_url': artworkUrl,
      'audio_url': audioUrl,
      'share_url': shareUrl,
      'duration': duration.inSeconds,
      'play_count': playCount,
      'is_liked': isLiked,
      'is_artist_followed': isArtistFollowed,
    };
  }
}