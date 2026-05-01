import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:rythmify/core/theme/app_theme.dart';
import 'package:rythmify/core/theme/messaging_themes.dart';
import 'package:rythmify/features/notifications/domain/entities/notification_entity.dart';
import 'package:rythmify/features/notifications/presentation/providers/follow_state_provider.dart';
import 'package:rythmify/features/notifications/presentation/providers/notifications_provider.dart';
import 'package:rythmify/features/messaging/presentation/providers/get_track_details_provider.dart';
import 'package:rythmify/features/notifications/presentation/providers/track_by_comment_provider.dart';
import 'package:rythmify/features/notifications/presentation/widgets/notification_tile.dart';

enum Filter { all, comments, likes, followings, reposts, reactions }

class NotificationsScreen extends ConsumerStatefulWidget {
  const NotificationsScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _NotificationScreenState();
}

class _NotificationScreenState extends ConsumerState<NotificationsScreen> {
  Filter _filter = Filter.all;
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(notificationsProvider.notifier).fetch();
    });

    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      ref.read(notificationsProvider.notifier).loadMore();
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(notificationsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        centerTitle: false,
        actions: [
          IconButton(
            key: const Key('notifications_filter_button'),
            onPressed: _showFilterSheet,
            icon: const Icon(Icons.tune_rounded),
          ),
        ],
      ),
      body: _buildBody(state),
    );
  }

  /// Applies [f] as the active filter. Triggers a server-side re-fetch for all
  /// types except [Filter.reactions] which has no API equivalent.
  void _setFilter(Filter f) {
    setState(() => _filter = f);
    if (f == Filter.reactions) return;
    ref.read(notificationsProvider.notifier).fetch(type: _toApiType(f));
  }

  /// Maps a [Filter] value to the `type` query parameter accepted by the API.
  /// Returns `null` for [Filter.all] (no filter applied server-side).
  String? _toApiType(Filter f) => switch (f) {
    Filter.all => null,
    Filter.comments => 'comment',
    Filter.likes => 'like',
    Filter.followings => 'follow',
    Filter.reposts => 'repost',
    Filter.reactions => null,
  };

  /// Shows the filter bottom sheet with all available [Filter] options.
  void _showFilterSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 8),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 8),
              _FilterOption(
                key: const Key('filter_option_all'),
                icon: Icons.notifications_rounded,
                label: 'Show all notifications',
                selected: _filter == Filter.all,
                onTap: () {
                  Navigator.pop(context);
                  _setFilter(Filter.all);
                },
              ),
              _FilterOption(
                key: const Key('filter_option_comments'),
                icon: Icons.chat_bubble_outline_rounded,
                label: 'Comments',
                selected: _filter == Filter.comments,
                onTap: () {
                  Navigator.pop(context);
                  _setFilter(Filter.comments);
                },
              ),
              _FilterOption(
                key: const Key('filter_option_likes'),
                icon: Icons.favorite_border_rounded,
                label: 'Likes',
                selected: _filter == Filter.likes,
                onTap: () {
                  Navigator.pop(context);
                  _setFilter(Filter.likes);
                },
              ),
              _FilterOption(
                key: const Key('filter_option_followings'),
                icon: Icons.person_outline_rounded,
                label: 'Followings',
                selected: _filter == Filter.followings,
                onTap: () {
                  Navigator.pop(context);
                  _setFilter(Filter.followings);
                },
              ),
              _FilterOption(
                key: const Key('filter_option_reposts'),
                icon: Icons.repeat_rounded,
                label: 'Reposts',
                selected: _filter == Filter.reposts,
                onTap: () {
                  Navigator.pop(context);
                  _setFilter(Filter.reposts);
                },
              ),
              _FilterOption(
                key: const Key('filter_option_reactions'),
                icon: Icons.sentiment_satisfied_outlined,
                label: 'Reactions',
                selected: _filter == Filter.reactions,
                onTap: () {
                  Navigator.pop(context);
                  _setFilter(Filter.reactions);
                },
              ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }

  /// Returns a human-readable section header for [date] (e.g. "Today", "Last 7 days").
  String _getDateTitle(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final notificationDay = DateTime(date.year, date.month, date.day);
    final diff = today.difference(notificationDay).inDays;

    if (diff == 0) return 'Today';
    if (diff == 1) return 'Yesterday';
    if (diff <= 7) return 'Last 7 days';
    if (diff <= 30) return 'Last 30 days';
    if (diff <= 60) return 'Last 2 months';
    if (diff <= 90) return 'Last 3 months';
    if (diff <= 180) return 'Last 6 months';
    if (diff <= 365) return 'Last year';
    return '${date.year}';
  }

  /// Returns items to display. Reactions have no API type so always empty.
  /// All other types are already filtered server-side.
  List<NotificationEntity> _filterItems(
    List<NotificationEntity> notifications,
  ) {
    if (_filter == Filter.reactions) return [];
    return notifications; // server already filtered by type
  }

  Widget _emptyListMessage() {
    String filterText='';
    if(_filter==Filter.comments){
      filterText='comments';
    }else if(_filter==Filter.followings){
      filterText='follow requests';
    }else if(_filter==Filter.likes){
      filterText='likes';
    }else if(_filter==Filter.reactions){
      filterText='reactions';
    }else if(_filter==Filter.reposts){
      filterText='reposts';
    }
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'You don\'t have any recent $filterText',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 17,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            const Text(
              'Switch to showing all to see recent notifications',
              style: TextStyle(color: Colors.grey, fontSize: 16, height: 1.5),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 48),
            SizedBox(
              width: double.infinity,
              child: TextButton(
                key: const Key('notifications_show_all_button'),
                onPressed: () => _setFilter(Filter.all),
                style: TextButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: const StadiumBorder(),
                ),
                child: const Text(
                  'Show all notifications',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Inserts date section headers into the flat notification list.
  List<dynamic> _buildItems(List<NotificationEntity> notifications) {
    final items = <dynamic>[];
    String? currentCategory;

    for (final notification in notifications) {
      final categ = _getDateTitle(notification.createdAt);
      if (categ != currentCategory) {
        items.add(categ);
        currentCategory = categ;
      }
      items.add(notification);
    }
    return items;
  }

  /// Navigates to the relevant screen for [notification].
  /// [embedId] is required for comment notifications to navigate to the track.
  void _onTap(NotificationEntity notification, String? embedId) {
    switch (notification.type) {
      case NotificationType.follow:
        context.push('/home/profile/${notification.actorId}');
      case NotificationType.like:
      case NotificationType.repost:
        if (notification.resourceId == null) return;
        if (notification.resourceType == ResourceType.playlist) {
          context.push('/home/playlist/${notification.resourceId}');
        } else if (notification.resourceType == ResourceType.track) {
          context.push('/home/behind-the-track/${notification.resourceId}');
        }
      case NotificationType.comment:
        if (embedId != null) context.push('/home/behind-the-track/$embedId');
      case NotificationType.newPostByFollowed:
        return;
    }
  }

  Widget _buildBody(NotificationsState state) {
    final followState = ref.watch(followStateProvider);
    if (state.isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          key: Key('notifications_loading_indicator'),
          color: AppTheme.primaryBrand,
        ),
      );
    }

    if (state.error != null && state.items.isEmpty) {
      return Center(
        child: Text(
          state.error!,
          key: const Key('notifications_error_text'),
          style: AppTheme.bodyMedium,
        ),
      );
    }

    if (state.items.isEmpty) {
      if (_filter == Filter.all) {
        return const Center(
          child: Column(
            key: Key('notifications_empty_all'),
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                'Nothing happened yet',
                style: MessagingThemes.inboxEmptyMsg,
              ),
              Text(
                'Interact with people you follow to get some\nactivities and updates',
                style: MessagingThemes.inboxEmptysubMsg,
              ),
            ],
          ),
        );
      } else {
        return _emptyListMessage();
      }
    }

    final filteredItems = _filterItems(state.items);
    if (filteredItems.isEmpty) return _emptyListMessage();
    final items = _buildItems(filteredItems);
    return RefreshIndicator(
      key: const Key('notifications_list'),
      color: AppTheme.primaryBrand,
      onRefresh: () => ref.read(notificationsProvider.notifier).fetch(),
      child: ListView.builder(
        controller: _scrollController,
        itemCount: items.length + (state.isLoadingMore ? 1 : 0) + 1,
        itemBuilder: (context, index) {
          if (state.isLoadingMore && index == items.length) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: CircularProgressIndicator(color: AppTheme.primaryBrand),
              ),
            );
          }
          if (index >= items.length) return const SizedBox(height: 80);
          final item = items[index];
          if (item is String) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
              child: Text(
                item,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            );
          }
          final notification = item as NotificationEntity;
          final commentData =
              notification.type == NotificationType.comment &&
                  notification.resourceId != null
              ? ref
                    .watch(trackByCommentProvider(notification.resourceId!))
                    .value
              : null;
          final likeRepostEmbed= (notification.type==NotificationType.like ||
                                    notification.type==NotificationType.repost)&&
                                  notification.resourceType==ResourceType.track&&
                                  notification.resourceId!=null
                                  ? ref.watch(getTrackDetailsProvider(notification.resourceId!)).value
                                  : null;
          final serverIsLiked = commentData?.isLikedByMe ?? false;
          final isCommentLiked =
              state.likedCommentIds.contains(notification.resourceId)
              ? !serverIsLiked
              : serverIsLiked;
          return NotificationTile(
            key: ValueKey(notification.id),
            notification: notification,
            onTap: () => _onTap(notification, commentData?.embed?.embedId),
            trackEmbed: commentData?.embed??likeRepostEmbed,
            isFollowing: followState[notification.actorId] ?? false,
            onFollowTap: () {
              ref
                  .read(notificationsProvider.notifier)
                  .toggleFollow(
                    notification.actorId,
                    followState[notification.actorId] ?? false,
                  );
            },
            onLikeTap: notification.resourceId != null
                ? () => ref
                      .read(notificationsProvider.notifier)
                      .toggleCommentLike(
                        notification.resourceId!,
                        isCommentLiked,
                      )
                : null,
            isCommentLiked: isCommentLiked,
          );
        },
      ),
    );
  }
}

class _FilterOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _FilterOption({
    super.key,
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = selected ? AppTheme.primaryBrand : Colors.white;
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        child: Row(
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(width: 16),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 16,
                fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
