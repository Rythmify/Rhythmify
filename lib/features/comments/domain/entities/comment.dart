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

  // Updated copyWith to accept all properties
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