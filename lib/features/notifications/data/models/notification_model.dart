import 'package:rythmify/features/notifications/domain/entities/notification_entity.dart';

/// Data-layer representation of a [NotificationEntity].
///
/// Extends [NotificationEntity] and adds [fromJson] to deserialise the
/// `GET /notifications` response. The actor object and resource_details
/// are nested inside each notification item.
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
    super.resourceImageUrl,
    required super.isRead,
    required super.createdAt,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    final actor = json['actor'] as Map<String, dynamic>? ?? {};
    final resourceDetails = json['resource_details'] as Map<String, dynamic>?;

    // actor['id'] may be null when the backend sends a stripped socket payload
    // (uses 'action_user_id' instead) or when actor data is incomplete.
    final actorId =
        actor['id'] as String? ?? json['action_user_id'] as String? ?? '';

    return NotificationModel(
      id: json['id'] as String,
      type: _mapType(json['type'] as String),
      actorId: actorId,
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
      // Tries cover_image first (tracks), falls back to cover_url (playlists).
      resourceImageUrl:
          resourceDetails?['cover_image'] as String? ??
          resourceDetails?['cover_url'] as String?,
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
