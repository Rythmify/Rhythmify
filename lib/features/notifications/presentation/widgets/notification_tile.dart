import 'package:flutter/material.dart';
import 'package:rythmify/core/theme/app_theme.dart';
import 'package:rythmify/features/messaging/domain/entities/shared_embed.dart';
import 'package:rythmify/features/messaging/presentation/widgets/avatar.dart';
import 'package:rythmify/features/notifications/domain/entities/notification_entity.dart';

class NotificationTile extends StatelessWidget {
  final NotificationEntity notification;
  final VoidCallback? onFollowTap;
  final VoidCallback? onLikeTap;
  final VoidCallback? onTap;
  final bool isCommentLiked;
  final bool isFollowing;

  /// Resolved track embed for comment-type notifications.
  /// Provides cover image, title, and track ID for navigation.
  final SharedEmbed? trackEmbed;

  const NotificationTile({
    super.key,
    required this.notification,
    this.onFollowTap,
    this.onLikeTap,
    this.onTap,
    this.isCommentLiked = false,
    this.isFollowing = false,
    this.trackEmbed,
  });

  @override
  Widget build(BuildContext context) {
    if (notification.type == NotificationType.newPostByFollowed) {
      return const SizedBox.shrink();
    }
    return InkWell(
      onTap: onTap,
      child: Container(
        color: notification.isRead ? Colors.transparent : Color(0xFF2F2F2F),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _AvatarWithBadge(
              avatar: notification.actorAvatar,
              type: notification.type,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(),
                  const SizedBox(height: 2),
                  _buildActionText(),
                  if (notification.type == NotificationType.comment)
                    _buildLikeButton(),
                ],
              ),
            ),
            const SizedBox(width: 8),
            _buildTrailing(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      children: [
        Flexible(
          child: Text(
            notification.actorDisplayName,
            style: AppTheme.bodyNormal,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(width: 6),
        Text(_timeAgo(notification.createdAt), style: AppTheme.bodyMedium),
      ],
    );
  }

  Widget _buildActionText() {
    switch (notification.type) {
      case NotificationType.follow:
        return Text('followed you', style: AppTheme.bodyMedium);
      case NotificationType.like:
        return _richAction(
          verb: 'liked your ${_resourceLabel()} ',
          title: notification.resourceTitle,
        );
      case NotificationType.repost:
        return _richAction(
          verb: 'reposted your ${_resourceLabel()} ',
          title: notification.resourceTitle,
        );
      case NotificationType.comment:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            RichText(
              maxLines: 5,
              overflow: TextOverflow.ellipsis,
              text: TextSpan(
                style: AppTheme.bodyMedium,
                children: [
                  const TextSpan(text: 'commented '),
                  if (notification.resourceContent != null)
                    TextSpan(
                      text: notification.resourceContent,
                      style: AppTheme.bodyNormal,
                    ),
                ],
              ),
            ),
            if (trackEmbed?.embedName != null)
              RichText(
                text: TextSpan(
                  style: AppTheme.bodyMedium,
                  children: [
                    const TextSpan(text: 'on '),
                    TextSpan(
                      text: trackEmbed!.embedName,
                      style: AppTheme.bodyNormal.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        );
      case NotificationType.newPostByFollowed:
        return const SizedBox.shrink();
    }
  }

  Widget _richAction({
    required String verb,
    String? title,
    String? suffix,
    String? suffixTitle,
  }) {
    return RichText(
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
      text: TextSpan(
        style: AppTheme.bodyMedium,
        children: [
          TextSpan(text: verb),
          if (title != null) TextSpan(text: title, style: AppTheme.bodyNormal),
          if (suffix != null) TextSpan(text: suffix),
          if (suffixTitle != null)
            TextSpan(text: suffixTitle, style: AppTheme.bodyNormal),
        ],
      ),
    );
  }

  String _resourceLabel() {
    switch (notification.resourceType) {
      case ResourceType.playlist:
        return 'playlist';
      case ResourceType.track:
      case ResourceType.comment:
      case null:
        return 'track';
    }
  }

  Widget _buildLikeButton() {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: GestureDetector(
        onTap: onLikeTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            border: Border.all(color: AppTheme.semiWhite, width: 1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                isCommentLiked
                    ? Icons.favorite_rounded
                    : Icons.favorite_border_rounded,
                color: isCommentLiked
                    ? const Color(0xFFE91E63)
                    : AppTheme.semiWhite,
                size: 14,
              ),
              const SizedBox(width: 4),
              Text('Like', style: AppTheme.bodyMedium),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTrailing() {
    if (notification.type == NotificationType.follow) {
      return _FollowButton(isFollowing: isFollowing, onTap: onFollowTap);
    } else if (notification.type == NotificationType.comment) {
      return _ResourceThumbnail(imageUrl: trackEmbed?.thumbnailUrl);
    }
    return _ResourceThumbnail(imageUrl: notification.resourceImageUrl);
  }

  String _timeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 1) return 'now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m';
    if (diff.inHours < 24) return '${diff.inHours}h';
    if (diff.inDays < 365) return '${diff.inDays}d';
    return '${(diff.inDays / 365).floor()}y';
  }
}

class _AvatarWithBadge extends StatelessWidget {
  final String? avatar;
  final NotificationType type;

  const _AvatarWithBadge({required this.avatar, required this.type});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 50,
      height: 50,
      child: Stack(
        children: [
          Avatar(img: avatar, radius: 25),
          Positioned(
            bottom: 0,
            right: 0,
            child: Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                color: _badgeColor,
                shape: BoxShape.circle,
                border: Border.all(color: AppTheme.background, width: 1.5),
              ),
              child: Icon(_badgeIcon, color: Colors.white, size: 11),
            ),
          ),
        ],
      ),
    );
  }

  Color get _badgeColor {
    switch (type) {
      case NotificationType.follow:
        return AppTheme.primaryBrand;
      case NotificationType.comment:
        return const Color(0xFF007AFF);
      case NotificationType.like:
        return const Color(0xFFE91E63);
      case NotificationType.repost:
        return const Color(0xFF00BCD4);
      case NotificationType.newPostByFollowed:
        return Colors.transparent;
    }
  }

  IconData get _badgeIcon {
    switch (type) {
      case NotificationType.follow:
        return Icons.person_add_rounded;
      case NotificationType.comment:
        return Icons.comment_rounded;
      case NotificationType.like:
        return Icons.favorite_rounded;
      case NotificationType.repost:
        return Icons.repeat_rounded;
      case NotificationType.newPostByFollowed:
        return Icons.notifications_rounded;
    }
  }
}

class _FollowButton extends StatelessWidget {
  final bool isFollowing;
  final VoidCallback? onTap;

  const _FollowButton({required this.isFollowing, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isFollowing ? const Color(0xFF3C3C3C) : Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          isFollowing ? 'Following' : 'Follow',
          style: AppTheme.labelLarge.copyWith(
            color: isFollowing ? Colors.white : Colors.black,
          ),
        ),
      ),
    );
  }
}

class _ResourceThumbnail extends StatelessWidget {
  final String? imageUrl;
  const _ResourceThumbnail({this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: SizedBox(
        width: 55,
        height: 55,
        child: imageUrl != null && imageUrl!.isNotEmpty
            ? Image.network(
                imageUrl!,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => _placeholder(),
              )
            : _placeholder(),
      ),
    );
  }

  Widget _placeholder() {
    return Container(
      color: AppTheme.perfectGrey,
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Image.asset('assets/icons/logo.png', color: Colors.white38),
      ),
    );
  }
}
