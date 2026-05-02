import 'package:rythmify/features/messaging/domain/entities/shared_embed.dart';

/// Data model representing a [SharedEmbed].
///
/// Extends [SharedEmbed] and provides JSON deserialization
/// for embed details fetched from the API (tracks, playlists, albums).
/// Used as the return type of [getTrackDetails] and [getPlaylistDetails]
/// in the data layer.
class SharedEmbedModel extends SharedEmbed {
  SharedEmbedModel({
    required super.embedId,
    required super.embedType,
    required super.embedName,
    super.artistName,
    super.thumbnailUrl,
  });

  /// Deserialises a [SharedEmbedModel] from an already-normalised [json] map.
  ///
  /// This factory is used internally after the datasource has normalised
  /// field names (e.g. mapping `track_id` → `embedId`). It is NOT called
  /// directly on raw API responses.
  factory SharedEmbedModel.fromJson(Map<String, dynamic> json) {
    return SharedEmbedModel(
      embedId: json['embedId'] as String,
      embedType: json['embedType'] as String,
      embedName: json['embedName'] as String,
      artistName: json['artistName'] as String,
      thumbnailUrl: json['thumbnailUrl'] as String,
    );
  }
}
