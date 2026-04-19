import '../../domain/entities/history_record.dart';

// part 'history_record_model.g.dart';

// @HiveType(typeId: 10) // Unique typeId for HistoryRecord
class HistoryRecordModel extends HistoryRecord {
  const HistoryRecordModel({
    required super.trackId,
    required super.playedAt,
    required super.durationPlayedSeconds,
  });

  factory HistoryRecordModel.fromEntity(HistoryRecord entity) {
    return HistoryRecordModel(
      trackId: entity.trackId,
      playedAt: entity.playedAt,
      durationPlayedSeconds: entity.durationPlayedSeconds,
    );
  }

  factory HistoryRecordModel.fromJson(Map<String, dynamic> json) {
    return HistoryRecordModel(
      trackId: json['track_id'] as String,
      playedAt: DateTime.parse(json['played_at'] as String),
      durationPlayedSeconds: json['duration_played_seconds'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'track_id': trackId,
      'played_at': playedAt.toIso8601String(),
      'duration_played_seconds': durationPlayedSeconds,
    };
  }
}
