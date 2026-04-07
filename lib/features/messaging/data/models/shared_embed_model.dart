import 'package:rythmify/features/messaging/domain/entities/shared_embed.dart';

class SharedEmbedModel extends SharedEmbed{
  SharedEmbedModel({
    required super.embedId,
    required super.embedType,
    required super.embedName,
    super.artistName,
    super.thumbnailUrl
  });

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