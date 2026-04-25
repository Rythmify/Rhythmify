import 'package:equatable/equatable.dart';

enum NotificationType { follow, like, repost, comment, newPostByFollowed }

enum ResourceType { track, playlist, comment }

class NotificationEntity extends Equatable {
  final String id;
  final NotificationType type;
  final String actorId;
  final String? actorUsername;
  final String actorDisplayName;
  final String? actorAvatar;
  final ResourceType? resourceType;
  final String? resourceId;
  final String? resourceTitle;
  final String? resourceContent; // comment text, from resource_details.content
  final bool isRead;
  final bool isActorFollowed;
  final DateTime createdAt;

  const NotificationEntity({
    required this.id,
    required this.type,
    required this.actorId,
    this.actorUsername,
    required this.actorDisplayName,
    this.actorAvatar,
    this.resourceType,
    this.resourceId,
    this.resourceTitle,
    this.resourceContent,
    required this.isRead,
    this.isActorFollowed = false,
    required this.createdAt,
  });

  NotificationEntity copyWith({bool? isRead, bool? isActorFollowed}) {
    return NotificationEntity(
      id: id,
      type: type,
      actorId: actorId,
      actorUsername: actorUsername,
      actorDisplayName: actorDisplayName,
      actorAvatar: actorAvatar,
      resourceType: resourceType,
      resourceId: resourceId,
      resourceTitle: resourceTitle,
      resourceContent: resourceContent,
      isRead: isRead ?? this.isRead,
      isActorFollowed: isActorFollowed ?? this.isActorFollowed,
      createdAt: createdAt,
    );
  }

  @override
  List<Object?> get props => [
    id,
    type,
    actorId,
    actorUsername,
    actorDisplayName,
    actorAvatar,
    resourceType,
    resourceId,
    resourceTitle,
    resourceContent,
    isRead,
    isActorFollowed,
    createdAt,
  ];
}
