import '../../domain/entities/comment.dart';

/// A Data Transfer Object (DTO) representing a raw comment payload from the API.
///
/// This model resides in the Data layer and is responsible for parsing
/// incoming JSON data and converting it into the Domain layer's [Comment] entity.
class CommentDto {
  /// The unique identifier of the comment.
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

  /// The track timestamp in milliseconds where the comment was left.
  final int timestamp;

  /// The ISO-8601 formatted creation date string.
  final String createdAt;

  /// The total number of likes this comment has received.
  final int likeCount;

  /// Whether the currently authenticated user has liked this comment.
  final bool isLikedByMe;

  /// The number of replies this comment has received.
  final int replyCount;

  /// The parent comment ID if this comment is a reply, otherwise null.
  final String? parentCommentId;

  /// Creates a new [CommentDto] instance.
  const CommentDto({
    required this.id,
    required this.trackId,
    required this.userId,
    required this.userDisplayName,
    this.userPfp,
    required this.content,
    required this.timestamp,
    required this.createdAt,
    required this.likeCount,
    required this.isLikedByMe,
    required this.replyCount,
    this.parentCommentId,
  });

  /// Factory constructor to create a [CommentDto] from a JSON map.
  ///
  /// Provides safe defaults for missing fields to prevent parsing errors.
  factory CommentDto.fromJson(Map<String, dynamic> json) {
    final author = json['author'] as Map<String, dynamic>? ?? {};

    return CommentDto(
      id: json['comment_id'] as String,
      trackId: json['track_id'] as String,
      userId: json['user_id'] as String,
      userDisplayName: author['display_name'] as String? ?? 'Unknown User',
      userPfp: author['profile_picture'] as String?,
      content: json['content'] as String,
      timestamp: json['track_timestamp'] as int? ?? 0,
      createdAt: json['created_at'] as String,
      likeCount: json['like_count'] as int? ?? 0,
      isLikedByMe: json['is_liked_by_me'] as bool? ?? false,
      replyCount: json['reply_count'] as int? ?? 0,
      parentCommentId: json['parent_comment_id'] as String?,
    );
  }

  /// Converts this DTO into a Domain [Comment] entity.
  ///
  /// This mapping method is crucial for Clean Architecture boundary separation,
  /// parsing the ISO string into a local [DateTime] object.
  Comment toDomain() {
    return Comment(
      id: id,
      trackId: trackId,
      userId: userId,
      userDisplayName: userDisplayName,
      userPfp: userPfp,
      content: content,
      trackTimestamp: timestamp,
      createdAt: DateTime.parse(createdAt).toLocal(),
      likesCount: likeCount,
      isLikedByMe: isLikedByMe,
      replyCount: replyCount,
      parentId: parentCommentId,
    );
  }
}
