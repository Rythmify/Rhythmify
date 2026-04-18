import 'package:equatable/equatable.dart';

/// Represents a user comment or reply on a specific track.
///
/// This entity belongs to the Domain layer and encapsulates the core data
/// associated with a single comment, including its content, author details,
/// and metadata like timestamps and like counts.
class Comment extends Equatable {
  /// The unique identifier for this comment.
  final String id;

  /// The unique identifier of the track this comment belongs to.
  final String trackId;

  /// The unique identifier of the user who authored this comment.
  final String userId;

  /// The display name of the user who authored this comment.
  final String userDisplayName;

  /// The optional profile picture URL of the user who authored this comment.
  final String? userPfp;

  /// The text content of the comment.
  final String content;

  /// The exact millisecond in the track where the comment was made.
  final int trackTimestamp;

  /// The date and time when this comment was originally created.
  final DateTime createdAt;

  /// The total number of likes this comment has received.
  final int likesCount;

  /// Indicates whether the currently authenticated user has liked this comment.
  final bool isLikedByMe;

  /// The total number of replies directed at this comment.
  final int replyCount;

  /// The optional parent comment ID, if this comment is a reply.
  final String? parentId;

  /// Creates a new [Comment] instance.
  const Comment({
    required this.id,
    required this.trackId,
    required this.userId,
    required this.userDisplayName,
    this.userPfp,
    required this.content,
    required this.trackTimestamp,
    required this.createdAt,
    required this.likesCount,
    required this.isLikedByMe,
    required this.replyCount,
    this.parentId,
  });

  /// Creates a copy of this [Comment] with the given fields replaced by the new values.
  Comment copyWith({
    String? id,
    String? trackId,
    String? userId,
    String? userDisplayName,
    String? userPfp,
    String? content,
    int? trackTimestamp,
    DateTime? createdAt,
    int? likesCount,
    bool? isLikedByMe,
    int? replyCount,
    String? parentId,
  }) {
    return Comment(
      id: id ?? this.id,
      trackId: trackId ?? this.trackId,
      userId: userId ?? this.userId,
      userDisplayName: userDisplayName ?? this.userDisplayName,
      userPfp: userPfp ?? this.userPfp,
      content: content ?? this.content,
      trackTimestamp: trackTimestamp ?? this.trackTimestamp,
      createdAt: createdAt ?? this.createdAt,
      likesCount: likesCount ?? this.likesCount,
      isLikedByMe: isLikedByMe ?? this.isLikedByMe,
      replyCount: replyCount ?? this.replyCount,
      parentId: parentId ?? this.parentId,
    );
  }

  @override
  List<Object?> get props => [
    id,
    trackId,
    userId,
    userDisplayName,
    userPfp,
    content,
    trackTimestamp,
    createdAt,
    likesCount,
    isLikedByMe,
    replyCount,
    parentId,
  ];
}
