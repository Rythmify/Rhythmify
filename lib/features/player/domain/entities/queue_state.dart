import 'package:equatable/equatable.dart';
import '../../../../core/domain/entities/track.dart';

enum QueueSource {
  playlist,
  album,
  station,
  search,
  userLikes,
  trending,
  feed,
  unknown
}

class QueueContext extends Equatable {
  final QueueSource type;
  final String sourceId;
  final Map<String, dynamic>? queryParams;

  const QueueContext({
    required this.type,
    required this.sourceId,
    this.queryParams,
  });

  @override
  List<Object?> get props => [type, sourceId, queryParams];
}

class AppQueueState extends Equatable {
  final QueueContext? context;
  final List<Track> history;
  final Track? currentTrack;
  final List<Track> upcomingTracks;
  final List<Track> unShuffledUpcomingTracks;
  final bool isShuffled;
  final bool hasMore;
  final int currentPage;

  const AppQueueState({
    this.context,
    this.history = const [],
    this.currentTrack,
    this.upcomingTracks = const [],
    this.unShuffledUpcomingTracks = const [],
    this.isShuffled = false,
    this.hasMore = false,
    this.currentPage = 1,
  });

  AppQueueState copyWith({
    QueueContext? context,
    List<Track>? history,
    Track? currentTrack,
    List<Track>? upcomingTracks,
    List<Track>? unShuffledUpcomingTracks,
    bool? isShuffled,
    bool? hasMore,
    int? currentPage,
  }) {
    return AppQueueState(
      context: context ?? this.context,
      history: history ?? this.history,
      currentTrack: currentTrack ?? this.currentTrack,
      upcomingTracks: upcomingTracks ?? this.upcomingTracks,
      unShuffledUpcomingTracks: unShuffledUpcomingTracks ?? this.unShuffledUpcomingTracks,
      isShuffled: isShuffled ?? this.isShuffled,
      hasMore: hasMore ?? this.hasMore,
      currentPage: currentPage ?? this.currentPage,
    );
  }

  @override
  List<Object?> get props => [
        context,
        history,
        currentTrack,
        upcomingTracks,
        unShuffledUpcomingTracks,
        isShuffled,
        hasMore,
        currentPage,
      ];
}
