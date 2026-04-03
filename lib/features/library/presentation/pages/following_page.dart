import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../providers/library_providers.dart';
import '../../domain/entities/library_entities.dart';

/// Displays a paginated list of all users the authenticated user follows.
///
/// Pull-to-refresh reloads the list from page 1. Scrolling near the bottom
/// triggers the next page load. Long-pressing a user shows an unfollow option.
class FollowingPage extends ConsumerStatefulWidget {
  const FollowingPage({super.key});

  @override
  ConsumerState<FollowingPage> createState() => _FollowingPageState();
}

class _FollowingPageState extends ConsumerState<FollowingPage> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
        ref.read(followingProvider.notifier).load();
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(followingProvider);

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(title: const Text('Following'), centerTitle: false),
      body: RefreshIndicator(
        color: AppTheme.primaryBrand,
        onRefresh: () => ref.read(followingProvider.notifier).load(refresh: true),
        child: _buildBody(context, state),
      ),
    );
  }

  Widget _buildBody(BuildContext context, FollowingState state) {
    if (state.isLoading && state.users.isEmpty) {
      return const Center(child: CircularProgressIndicator(color: AppTheme.primaryBrand));
    }

    if (state.error != null && state.users.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(state.error!, style: AppTheme.bodyMedium),
            const SizedBox(height: 16),
            ElevatedButton(
              key: const Key('following_retry_button'),
              onPressed: () => ref.read(followingProvider.notifier).load(refresh: true),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (state.users.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.people_outline, color: AppTheme.textSecondary, size: 56),
            const SizedBox(height: 16),
            Text('Not following anyone yet', style: AppTheme.titleMedium.copyWith(color: AppTheme.textSecondary)),
            const SizedBox(height: 8),
            Text('Artists you follow will appear here.', style: AppTheme.bodyMedium),
          ],
        ),
      );
    }

    return ListView.builder(
      key: const Key('following_list_view'),
      controller: _scrollController,
      itemCount: state.users.length + 1,
      itemBuilder: (context, index) {
        if (index == state.users.length) {
          return state.isLoading
              ? const Padding(padding: EdgeInsets.all(16), child: Center(child: CircularProgressIndicator(color: AppTheme.primaryBrand, strokeWidth: 2)))
              : const SizedBox.shrink();
        }
        return _UserTile(user: state.users[index]);
      },
    );
  }
}

class _UserTile extends ConsumerWidget {
  final FollowedUser user;

  const _UserTile({required this.user});

  Future<void> _showUnfollowDialog(BuildContext context, WidgetRef ref) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppTheme.surface,
        title: const Text('Unfollow?', style: TextStyle(color: Colors.white)),
        content: Text('Stop following ${user.displayName}?', style: AppTheme.bodyMedium),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: Text('Cancel', style: AppTheme.labelLarge)),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('Unfollow', style: AppTheme.labelLarge.copyWith(color: AppTheme.primaryBrand)),
          ),
        ],
      ),
    );
    if (confirm == true) {
      ref.read(followingProvider.notifier).unfollow(user.id);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListTile(
      key: Key('following_item_${user.id}_list_tile'),
      onTap: () => context.push('/profile/${user.id}'),
      onLongPress: () => _showUnfollowDialog(context, ref),
      leading: CircleAvatar(
        radius: 24,
        backgroundColor: AppTheme.surface,
        backgroundImage: user.avatarUrl != null ? CachedNetworkImageProvider(user.avatarUrl!) : null,
        child: user.avatarUrl == null ? const Icon(Icons.person, color: AppTheme.textSecondary) : null,
      ),
      title: Row(
        children: [
          Flexible(
            child: Text(
              user.displayName,
              key: Key('following_item_${user.id}_name_text'),
              style: AppTheme.labelLarge,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (user.isVerified) ...[
            const SizedBox(width: 4),
            const Icon(Icons.verified, size: 14, color: AppTheme.primaryBrand),
          ],
        ],
      ),
      subtitle: Text(
        '${_formatCount(user.followersCount)} followers',
        key: Key('following_item_${user.id}_followers_text'),
        style: AppTheme.labelSmall,
      ),
      trailing: OutlinedButton(
        key: Key('following_item_${user.id}_following_button'),
        onPressed: () => _showUnfollowDialog(context, ref),
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: AppTheme.textSecondary),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          shape: const StadiumBorder(),
        ),
        child: const Text('Following', style: TextStyle(color: Colors.white, fontSize: 12)),
      ),
    );
  }

  String _formatCount(int count) {
    if (count >= 1000000) return '${(count / 1000000).toStringAsFixed(1)}M';
    if (count >= 1000) return '${(count / 1000).toStringAsFixed(1)}K';
    return count.toString();
  }
}
