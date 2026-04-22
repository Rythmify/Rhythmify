import 'package:equatable/equatable.dart';

class HistoryRecord extends Equatable {
  final String trackId;
  final DateTime playedAt;
  final int durationPlayedSeconds;

  const HistoryRecord({
    required this.trackId,
    required this.playedAt,
    required this.durationPlayedSeconds,
  });

  @override
  List<Object?> get props => [trackId, playedAt, durationPlayedSeconds];
}
