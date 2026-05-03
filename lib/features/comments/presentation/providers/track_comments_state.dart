import 'package:equatable/equatable.dart';
import '../../domain/entities/comment.dart';
import '../../domain/repositories/comment_repository.dart';

/// Holds the UI state for a paginated list of comments.
///
/// This state class is used by the Presentation layer to track the loaded
/// comments, pagination metadata, and the current sorting strategy.
class TrackCommentsState extends Equatable {
  /// The list of currently loaded [Comment] entities.
  final List<Comment> comments;

  /// The current page number fetched from the repository.
  final int currentPage;

  /// Indicates whether the end of the paginated list has been reached.
  final bool hasReachedMax;

  /// Indicates whether a network request is currently fetching the next page.
  final bool isFetchingNextPage;

  /// The currently selected sorting strategy for the comments.
  final CommentSortType sortType;

  /// The total number of root comments available for the track.
  final int totalCommentCount;

  /// Creates a [TrackCommentsState] with all its required properties.
  const TrackCommentsState({
    required this.comments,
    required this.currentPage,
    required this.hasReachedMax,
    required this.isFetchingNextPage,
    required this.sortType,
    required this.totalCommentCount,
  });

  /// Factory constructor to create an initial, empty [TrackCommentsState].
  ///
  /// Used when the state is first initialized before any data is fetched.
  factory TrackCommentsState.initial() {
    return const TrackCommentsState(
      comments: [],
      currentPage: 1,
      hasReachedMax: false,
      isFetchingNextPage: false,
      sortType: CommentSortType.newest,
      totalCommentCount: 0,
    );
  }

  /// Creates a copy of this state with the given fields replaced by new values.
  TrackCommentsState copyWith({
    List<Comment>? comments,
    int? currentPage,
    bool? hasReachedMax,
    bool? isFetchingNextPage,
    CommentSortType? sortType,
    int? totalCommentCount,
  }) {
    return TrackCommentsState(
      comments: comments ?? this.comments,
      currentPage: currentPage ?? this.currentPage,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      isFetchingNextPage: isFetchingNextPage ?? this.isFetchingNextPage,
      sortType: sortType ?? this.sortType,
      totalCommentCount: totalCommentCount ?? this.totalCommentCount,
    );
  }

  @override
  List<Object?> get props => [
    comments,
    currentPage,
    hasReachedMax,
    isFetchingNextPage,
    sortType,
    totalCommentCount,
  ];
}
