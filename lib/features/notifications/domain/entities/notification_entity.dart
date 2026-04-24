import 'package:equatable/equatable.dart';

enum NotificationType{ follow, comment, repost, like }

class NotificationEntity extends Equatable{
  final String id;
  final NotificationType type;
  final String actorName;
  final String? actorAvatar;
  final DateTime createdAt;
  final bool isRead;

  //at NotificationType==follow
  final bool? isFollowing; 

  //at NotificationType == (follow || repost || like)
  final String? trackName;
  final String? trackImageUrl;

  //at NotificationType==comment
  final String? commentText;
  final bool? isCommentLiked;

  const NotificationEntity({
    required this.id,
    required this.type,
    required this.actorName,
    this.actorAvatar,
    required this.createdAt,
    required this.isRead,
    this.isFollowing=false,
    this.commentText,
    this.isCommentLiked=false,
    this.trackName,
    this.trackImageUrl
  });

  @override
  List<Object?> get props=>[
    id,
    type,
    actorName,
    actorAvatar,
    createdAt,
    isRead,
    isFollowing,
    trackName,
    trackImageUrl,
    commentText,
    isCommentLiked,
  ];
}