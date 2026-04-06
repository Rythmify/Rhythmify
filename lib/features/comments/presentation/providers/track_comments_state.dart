import 'package:equatable/equatable.dart';
import '../../domain/entities/comment.dart';
import '../../domain/repositories/comment_repository.dart';

/// Holds the UI state for a paginated list of comments.
class TrackCommentsState extends Equatable {
  final List<Comment> comments;
  final int currentPage;
  final bool hasReachedMax;
  final bool isFetchingNextPage;
  final CommentSortType sortType;

  const TrackCommentsState({
    required this.comments,
    required this.currentPage,
    required this.hasReachedMax,
    required this.isFetchingNextPage,
    required this.sortType,
  });

  /// Initial factory for a clean slate.
  factory TrackCommentsState.initial() {
    return const TrackCommentsState(
      comments: [],
      currentPage: 1,
      hasReachedMax: false,
      isFetchingNextPage: false,
      sortType: CommentSortType.newest,
    );
  }

  TrackCommentsState copyWith({
    List<Comment>? comments,
    int? currentPage,
    bool? hasReachedMax,
    bool? isFetchingNextPage,
    CommentSortType? sortType,
  }) {
    return TrackCommentsState(
      comments: comments ?? this.comments,
      currentPage: currentPage ?? this.currentPage,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      isFetchingNextPage: isFetchingNextPage ?? this.isFetchingNextPage,
      sortType: sortType ?? this.sortType,
    );
  }

  @override
  List<Object?> get props => [
    comments,
    currentPage,
    hasReachedMax,
    isFetchingNextPage,
    sortType,
  ];
}
