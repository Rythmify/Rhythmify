import 'package:rythmify/features/notifications/domain/entities/notification_entity.dart';

class NotificationModel extends NotificationEntity {
  const NotificationModel({
    required super.id,
    required super.type,
    required super.actorId,
    super.actorUsername,
    required super.actorDisplayName,
    super.actorAvatar,
    super.resourceType,
    super.resourceId,
    super.resourceTitle,
    super.resourceContent,
    required super.isRead,
    required super.createdAt,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    final actor = json['actor'] as Map<String, dynamic>? ?? {};
    final resourceDetails = json['resource_details'] as Map<String, dynamic>?;

    return NotificationModel(
      id: json['id'] as String,
      type: _mapType(json['type'] as String),
      actorId: actor['id'] as String,
      actorUsername: actor['username'] as String?,
      actorDisplayName:
          (actor['display_name'] as String?) ??
          (actor['username'] as String?) ??
          'Unknown',
      actorAvatar: actor['avatar'] as String?,
      resourceType: _mapResourceType(json['resource_type'] as String?),
      resourceId: json['resource_id'] as String?,
      resourceTitle: resourceDetails?['title'] as String?,
      resourceContent: resourceDetails?['content'] as String?,
      isRead: json['is_read'] as bool? ?? false,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  static NotificationType _mapType(String type) {
    switch (type) {
      case 'follow':
        return NotificationType.follow;
      case 'like':
        return NotificationType.like;
      case 'repost':
        return NotificationType.repost;
      case 'comment':
        return NotificationType.comment;
      case 'new_post_by_followed':
        return NotificationType.newPostByFollowed;
      default:
        return NotificationType.newPostByFollowed;
    }
  }

  static ResourceType? _mapResourceType(String? type) {
    switch (type) {
      case 'track':
        return ResourceType.track;
      case 'playlist':
        return ResourceType.playlist;
      case 'comment':
        return ResourceType.comment;
      default:
        return null;
    }
  }
}
