import 'package:equatable/equatable.dart';
import 'queue_item.dart';

enum QueueSource {
  playlist,
  album,
  track,
  mix,
  station,
  genre,
  userLikes,
  trending,
  feed,
  listeningHistory,
  reposts,
  userTracks,
  search,
  unknown,
}

class QueueContext extends Equatable {
  final QueueSource type;
  final String? sourceId;
  final String? targetUserId;
  final Map<String, dynamic>? queryParams;

  const QueueContext({
    required this.type,
    this.sourceId,
    this.targetUserId,
    this.queryParams,
  });

  @override
  List<Object?> get props => [type, sourceId, targetUserId, queryParams];
}

class AppQueueState extends Equatable {
  final QueueContext? context;
  final List<QueueItem> history;
  final QueueItem? currentTrack;
  final List<QueueItem> upcomingTracks;
  final List<QueueItem> unShuffledUpcomingTracks;
  final List<QueueItem> recommendedTracks;
  final bool isShuffled;
  final bool hasMore;
  final int currentPage;
  final bool isLoadingRecommendations;

  const AppQueueState({
    this.context,
    this.history = const [],
    this.currentTrack,
    this.upcomingTracks = const [],
    this.unShuffledUpcomingTracks = const [],
    this.recommendedTracks = const [],
    this.isShuffled = false,
    this.hasMore = false,
    this.currentPage = 1,
    this.isLoadingRecommendations = false,
  });

  AppQueueState copyWith({
    QueueContext? context,
    List<QueueItem>? history,
    QueueItem? currentTrack,
    List<QueueItem>? upcomingTracks,
    List<QueueItem>? unShuffledUpcomingTracks,
    List<QueueItem>? recommendedTracks,
    bool? isShuffled,
    bool? hasMore,
    int? currentPage,
    bool? isLoadingRecommendations,
  }) {
    return AppQueueState(
      context: context ?? this.context,
      history: history ?? this.history,
      currentTrack: currentTrack ?? this.currentTrack,
      upcomingTracks: upcomingTracks ?? this.upcomingTracks,
      unShuffledUpcomingTracks:
          unShuffledUpcomingTracks ?? this.unShuffledUpcomingTracks,
      recommendedTracks: recommendedTracks ?? this.recommendedTracks,
      isShuffled: isShuffled ?? this.isShuffled,
      hasMore: hasMore ?? this.hasMore,
      currentPage: currentPage ?? this.currentPage,
      isLoadingRecommendations:
          isLoadingRecommendations ?? this.isLoadingRecommendations,
    );
  }

  @override
  List<Object?> get props => [
    context,
    history,
    currentTrack,
    upcomingTracks,
    unShuffledUpcomingTracks,
    recommendedTracks,
    isShuffled,
    hasMore,
    currentPage,
    isLoadingRecommendations,
  ];
}
