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

  // UUID v4 pattern: 8-4-4-4-12 hex chars separated by hyphens
  static final _uuidRegex = RegExp(
    r'^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$',
    caseSensitive: false,
  );

  /// Returns true only for real server-issued UUIDs.
  /// Locally-generated IDs (prefixed 'opt_' / 'manual_') return false.
  bool get hasServerUuid =>
      queueItemId != null && _uuidRegex.hasMatch(queueItemId!);

  Map<String, dynamic> toJson() {
    final trackJson = TrackDto.toJson(track);
    return {
      ...trackJson,
      // Only include queue_item_id when it is a real UUID. Sending fake local
      // IDs causes a 400 VALIDATION_FAILED from the backend.
      if (hasServerUuid) 'queue_item_id': queueItemId,
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
