import 'package:equatable/equatable.dart';
import '../../../../core/domain/entities/track.dart';
import '../../../../core/data/models/track_dto.dart';

class QueueItem extends Equatable {
  final String? queueItemId;
  final Track track;
  final String queueBucket; // 'next_up' or 'context'
  final String? sourceType;
  final String? sourceId;
  final bool isRecommended;

  const QueueItem({
    this.queueItemId,
    required this.track,
    this.queueBucket = 'context',
    this.sourceType,
    this.sourceId,
    this.isRecommended = false,
  });

  factory QueueItem.fromJson(Map<String, dynamic> json) {
    return QueueItem(
      queueItemId: json['queue_item_id'] as String?,
      track: TrackDto.fromJson(json),
      queueBucket: json['queue_bucket'] as String? ?? 'context',
      sourceType: json['source_type'] as String?,
      sourceId: json['source_id'] as String?,
      isRecommended: json['is_recommended'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    final trackJson = TrackDto.toJson(track);
    return {
      ...trackJson,
      'queue_item_id': queueItemId,
      'queue_bucket': queueBucket,
      'source_type': sourceType,
      'source_id': sourceId,
      'is_recommended': isRecommended,
    };
  }

  QueueItem copyWith({
    String? queueItemId,
    Track? track,
    String? queueBucket,
    String? sourceType,
    String? sourceId,
    bool? isRecommended,
  }) {
    return QueueItem(
      queueItemId: queueItemId ?? this.queueItemId,
      track: track ?? this.track,
      queueBucket: queueBucket ?? this.queueBucket,
      sourceType: sourceType ?? this.sourceType,
      sourceId: sourceId ?? this.sourceId,
      isRecommended: isRecommended ?? this.isRecommended,
    );
  }

  @override
  List<Object?> get props => [
    queueItemId,
    track,
    queueBucket,
    sourceType,
    sourceId,
    isRecommended,
  ];
}
