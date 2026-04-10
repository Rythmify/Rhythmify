import '../../domain/entities/comment.dart';

class CommentDto {
  final String id;
  final String trackId;
  final String userId;
  final String userDisplayName;
  final String? userPfp;
  final String content;
  final int timestamp;
  final String createdAt;
  final int likeCount;
  final bool isLikedByMe;
  final int replyCount;
  final String? parentCommentId;

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

  factory CommentDto.fromJson(Map<String, dynamic> json) {
    final author = json['author'] as Map<String, dynamic>? ?? {};
    final rawUserPfp =
        author['avatar_url'] as String? ?? author['profile_picture'] as String?;

    return CommentDto(
      id: json['comment_id'] as String,
      trackId: json['track_id'] as String,
      userId: json['user_id'] as String,
      userDisplayName: author['display_name'] as String? ?? 'Unknown User',
      userPfp: rawUserPfp?.trim().isEmpty == true ? null : rawUserPfp?.trim(),
      content: json['content'] as String,
      timestamp: json['track_timestamp'] as int? ?? 0,
      createdAt: json['created_at'] as String,
      likeCount: json['like_count'] as int? ?? 0,
      isLikedByMe: json['is_liked_by_me'] as bool? ?? false,
      replyCount: json['reply_count'] as int? ?? 0,
      parentCommentId: json['parent_comment_id'] as String?,
    );
  }

  // Mapper to Domain Entity
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
