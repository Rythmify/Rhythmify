import 'package:equatable/equatable.dart';

/// The category of action that triggered a notification.
enum NotificationType { follow, like, repost, comment, newPostByFollowed }

/// The kind of content the notification refers to.
enum ResourceType { track, playlist, comment }

/// Core domain object representing a single in-app notification.
///
/// Notifications are immutable; use [copyWith] to produce updated copies.
/// [isActorFollowed] is not parsed from the API response — the live follow
/// state is managed separately via [followStateProvider].
class NotificationEntity extends Equatable {
  final String id;
  final NotificationType type;

  /// ID of the user who performed the action that triggered this notification.
  final String actorId;
  final String? actorUsername;
  final String actorDisplayName;
  final String? actorAvatar;

  /// The kind of content associated with the notification (track, playlist, comment).
  final ResourceType? resourceType;

  /// ID of the associated resource, used for navigation.
  final String? resourceId;

  /// Display title of the resource (e.g. track name).
  final String? resourceTitle;

  /// Body text of the resource (e.g. comment content).
  final String? resourceContent;

  /// Cover image URL for the resource thumbnail. `null` shows the logo placeholder.
  final String? resourceImageUrl;

  /// Whether the notification has been acknowledged by the backend.
  final bool isRead;

  /// Cached follow state for the actor — always `false` by default.
  /// The real value comes from [followStateProvider] via [FollowStateNotifier].
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
    this.resourceImageUrl,
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
      resourceImageUrl: resourceImageUrl,
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
    resourceImageUrl,
    isRead,
    isActorFollowed,
    createdAt,
  ];
}
