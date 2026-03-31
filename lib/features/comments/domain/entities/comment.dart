import 'package:equatable/equatable.dart';

class Comment extends Equatable {
  final String id;
  final String trackId;
  final String userId;
  final String userDisplayName;
  final String? userPfp;
  final String content;
  final int trackTimestamp;
  final DateTime createdAt;
  final int likesCount;
  final bool isLikedByMe;
  final int replyCount;
  final String? parentId;

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

  // For local UI optimistic updates
  // (ex: liking a comment)
  
  Comment copyWith({
    int? likesCount,
    bool? isLikedByMe,
    int? replyCount,
  }) {
    return Comment(
      id: id,
      trackId: trackId,
      userId: userId,
      userDisplayName: userDisplayName,
      userPfp: userPfp,
      content: content,
      trackTimestamp: trackTimestamp,
      createdAt: createdAt,
      likesCount: likesCount ?? this.likesCount,
      isLikedByMe: isLikedByMe ?? this.isLikedByMe,
      replyCount: replyCount ?? this.replyCount,
      parentId: parentId,
    );
  }

  @override
  List<Object?> get props =>
  [
    id, trackId, userId, userDisplayName,
    userPfp, content, trackTimestamp, createdAt, 
    likesCount, isLikedByMe, replyCount, parentId,
  ];
}