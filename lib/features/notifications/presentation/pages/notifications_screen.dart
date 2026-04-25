import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:rythmify/core/theme/app_theme.dart';
import 'package:rythmify/core/theme/messaging_themes.dart';
import 'package:rythmify/features/notifications/domain/entities/notification_entity.dart';
import 'package:rythmify/features/notifications/presentation/providers/follow_state_provider.dart';
import 'package:rythmify/features/notifications/presentation/providers/notifications_provider.dart';
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
            onPressed: _showFilterSheet,
            icon: const Icon(Icons.tune_rounded),
          ),
        ],
      ),
      body: _buildBody(state),
    );
  }

  void _setFilter(Filter f) {
    setState(() => _filter = f);
    if (f != Filter.all) {
      ref.read(notificationsProvider.notifier).loadAll();
    }
  }

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
                icon: Icons.notifications_rounded,
                label: 'Show all notifications',
                selected: _filter == Filter.all,
                onTap: () {
                  Navigator.pop(context);
                  _setFilter(Filter.all);
                },
              ),
              _FilterOption(
                icon: Icons.chat_bubble_outline_rounded,
                label: 'Comments',
                selected: _filter == Filter.comments,
                onTap: () {
                  Navigator.pop(context);
                  _setFilter(Filter.comments);
                },
              ),
              _FilterOption(
                icon: Icons.favorite_border_rounded,
                label: 'Likes',
                selected: _filter == Filter.likes,
                onTap: () {
                  Navigator.pop(context);
                  _setFilter(Filter.likes);
                },
              ),
              _FilterOption(
                icon: Icons.person_outline_rounded,
                label: 'Followings',
                selected: _filter == Filter.followings,
                onTap: () {
                  Navigator.pop(context);
                  _setFilter(Filter.followings);
                },
              ),
              _FilterOption(
                icon: Icons.repeat_rounded,
                label: 'Reposts',
                selected: _filter == Filter.reposts,
                onTap: () {
                  Navigator.pop(context);
                  _setFilter(Filter.reposts);
                },
              ),
              _FilterOption(
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

  List<NotificationEntity> _filterItems(
    List<NotificationEntity> notifications,
  ) {
    switch (_filter) {
      case Filter.all:
        return notifications;
      case Filter.comments:
        return notifications
            .where((n) => n.type == NotificationType.comment)
            .toList();
      case Filter.followings:
        return notifications
            .where((n) => n.type == NotificationType.follow)
            .toList();
      case Filter.likes:
        return notifications
            .where((n) => n.type == NotificationType.like)
            .toList();
      case Filter.reposts:
        return notifications
            .where((n) => n.type == NotificationType.repost)
            .toList();
      case Filter.reactions:
        return [];
    }
  }

  Widget _emptyListMessage() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'You don\'t have any recent $_filter',
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
              style: TextStyle(color: Colors.grey, fontSize: 14, height: 1.5),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 48),
            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: () => _setFilter(Filter.all),
                style: TextButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: const StadiumBorder(),
                ),
                child: const Text(
                  'Show all notifications',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

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

  void _onTap(NotificationEntity notification) {
    switch (notification.type) {
      case NotificationType.follow:
        context.push('/profile/${notification.actorId}');
      case NotificationType.like:
      case NotificationType.repost:
        if (notification.resourceId == null) return;
        if (notification.resourceType == ResourceType.playlist) {
          context.push('/playlist/${notification.resourceId}');
        } else if (notification.resourceType == ResourceType.track) {
          context.push('/behind-the-track/${notification.resourceId}');
        }
      case NotificationType.newPostByFollowed:
      case NotificationType.comment:
        return;
    }
  }

  Widget _buildBody(NotificationsState state) {
    final followState = ref.watch(followStateProvider);
    if (state.isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppTheme.primaryBrand),
      );
    }

    if (state.error != null && state.items.isEmpty) {
      return Center(child: Text(state.error!, style: AppTheme.bodyMedium));
    }

    if (state.items.isEmpty) {
      if (_filter == Filter.all) {
        return const Center(
          child: Column(
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
      color: AppTheme.primaryBrand,
      onRefresh: () => ref.read(notificationsProvider.notifier).fetch(),
      child: ListView.builder(
        controller: _scrollController,
        itemCount: items.length + (state.isLoadingMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == items.length) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: CircularProgressIndicator(color: AppTheme.primaryBrand),
              ),
            );
          }
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
          return NotificationTile(
            notification: notification,
            onTap: () => _onTap(notification),
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
                      .toggleCommentLike(notification.resourceId!)
                : null,
            isCommentLiked: state.likedCommentIds.contains(
              notification.resourceId,
            ),
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
