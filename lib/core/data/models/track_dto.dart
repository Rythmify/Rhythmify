import '../../domain/entities/track.dart';

class TrackDto {
  static Track fromJson(Map<dynamic, dynamic> json) {
    // Ensure we have a Map<String, dynamic> for internal logic
    final Map<String, dynamic> normalizedJson = Map<String, dynamic>.from(json);

    // Some responses wrap data in a 'data' field
    final Map<String, dynamic> data = normalizedJson.containsKey('data')
        ? Map<String, dynamic>.from(normalizedJson['data'] as Map)
        : normalizedJson;

    return Track(
      id: data['id'] as String? ?? '',
      userId: data['user_id'] as String? ?? data['artist_id'] as String? ?? '',
      title: data['title'] as String? ?? '',
      artist:
          data['display_name'] as String? ??
          data['artist_name'] as String? ??
          data['artist'] as String? ??
          data['artists'] as String? ??
          data['user']?['display_name'] as String? ??
          '',
      artistUsername:
          data['username'] as String? ??
          data['artist_username'] as String? ??
          data['user']?['username'] as String?,

      artistPfp:
          data['profile_picture'] as String? ??
          data['artist_pfp'] as String? ??
          data['user']?['profile_picture'] as String?,
      artistCity: data['artist_city'] as String?,
      artistCountry: data['artist_country'] as String?,
      description: data['description'] as String?,
      coverImage:
          data['cover_image'] as String? ?? data['artwork_url'] as String?,
      audioUrl:
          data['stream_url'] as String? ?? data['audio_url'] as String? ?? '',
      streamUrl: data['stream_url'] as String?,
      waveformUrl: data['waveform_url'] as String?,
      duration: Duration(
        seconds:
            data['duration'] as int? ?? data['duration_seconds'] as int? ?? 0,
      ),
      createdAt:
          DateTime.tryParse(
            data['liked_at'] as String? ?? data['created_at'] as String? ?? '',
          ) ??
          DateTime.now(),
      updatedAt: data['updated_at'] != null
          ? DateTime.tryParse(data['updated_at']?.toString() ?? '')
          : null,

      playCount: data['play_count'] as int? ?? 0,
      likeCount: data['like_count'] as int? ?? 0,
      commentCount: data['comment_count'] as int? ?? 0,
      repostCount: data['repost_count'] as int? ?? 0,

      isLiked:
          data['is_liked'] as bool? ?? data['is_liked_by_me'] as bool? ?? false,
      isReposted:
          data['is_reposted'] as bool? ??
          data['is_reposted_by_me'] as bool? ??
          false,
      isArtistFollowed:
          data['is_artist_followed'] as bool? ??
          data['is_artist_followed_by_me'] as bool? ??
          false,

      tags:
          (data['tags'] as List<dynamic>?)?.map((e) => e.toString()).toList() ??
          const [],

      waveformData: data['waveform_data'] != null
          ? List<double>.from(
              data['waveform_data'].map((x) => (x as num).toDouble()),
            )
          : null,

      genre: data['genre'] as String?,

      artists: data['artists'] as String?,

      recordLabel: data['record_label'] as String?,
      releaseDate: data['release_date'] as String?,
      explicitContent: data['explicit_content'] as bool? ?? false,
      isTrending: data['is_trending'] as bool? ?? false,
      isFeatured: data['is_featured'] as bool? ?? false,
      isPublic: data['is_public'] as bool? ?? true,
      isHidden: data['is_hidden'] as bool? ?? false,
      isGeoBlocked: data['is_geo_blocked'] as bool? ?? false,
      geoRestrictionType: data['geo_restriction_type'] as String?,
      geoRegions:
          (data['geo_regions'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      status: data['status'] as String?,
    );
  }

  static Map<String, dynamic> toJson(Track track) {
    return {
      'id': track.id,
      'user_id': track.userId,
      'title': track.title,
      'artist': track.artist,
      'artist_username': track.artistUsername,
      'artist_pfp': track.artistPfp,
      'artist_city': track.artistCity,
      'artist_country': track.artistCountry,
      'description': track.description,
      'cover_image': track.coverImage,
      'audio_url': track.audioUrl,
      'stream_url': track.streamUrl,
      'waveform_url': track.waveformUrl,
      'duration': track.duration.inSeconds,
      'created_at': track.createdAt.toIso8601String(),
      'updated_at': track.updatedAt?.toIso8601String(),

      'play_count': track.playCount,
      'like_count': track.likeCount,
      'comment_count': track.commentCount,
      'repost_count': track.repostCount,

      'is_liked': track.isLiked,
      'is_reposted': track.isReposted,
      'is_artist_followed': track.isArtistFollowed,

      'tags': track.tags,
      'waveform_data': track.waveformData,

      'genre': track.genre,
      'artists': track.artists,
      'record_label': track.recordLabel,
      'release_date': track.releaseDate,
      'explicit_content': track.explicitContent,
      'is_trending': track.isTrending,
      'is_featured': track.isFeatured,
      'is_public': track.isPublic,
      'is_hidden': track.isHidden,
      'is_geo_blocked': track.isGeoBlocked,
      'geo_restriction_type': track.geoRestrictionType,
      'geo_regions': track.geoRegions,
      'status': track.status,
    };
  }
}
