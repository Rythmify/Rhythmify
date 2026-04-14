import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../domain/usecases/get_user_connections_usecase.dart';
import '../providers/profile_connections_provider.dart';
import '../providers/profile_connections_state.dart';
import '../widgets/profile_user_list_tile.dart';

/// Paginated profile connections screen for followers/following.
class ProfileConnectionsPage extends ConsumerStatefulWidget {
  /// User whose connections should be loaded.
  final String userId;

  /// Connections mode: followers or following.
  final ProfileConnectionsType type;

  /// Creates a [ProfileConnectionsPage].
  const ProfileConnectionsPage({
    super.key,
    required this.userId,
    required this.type,
  });

  @override
  ConsumerState<ProfileConnectionsPage> createState() =>
      _ProfileConnectionsPageState();
}

/// State object that handles pagination triggers.
class _ProfileConnectionsPageState
    extends ConsumerState<ProfileConnectionsPage> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    Future.microtask(_loadInitial);
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController
      ..removeListener(_onScroll)
      ..dispose();
    super.dispose();
  }

  /// Loads first page.
  Future<void> _loadInitial() {
    return ref
        .read(profileConnectionsProvider.notifier)
        .loadConnections(
          userId: widget.userId,
          type: widget.type,
          refresh: true,
        );
  }

  /// Loads next page when near the end.
  void _onScroll() {
    if (!_scrollController.hasClients) return;
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      ref
          .read(profileConnectionsProvider.notifier)
          .loadConnections(userId: widget.userId, type: widget.type);
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(profileConnectionsProvider);
    final title = widget.type == ProfileConnectionsType.followers
        ? 'Followers'
        : 'Following';

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: Text(title),
        leading: IconButton(
          key: const Key('profile_connections_back_button'),
          onPressed: () => context.pop(),
          icon: const Icon(Icons.arrow_back),
        ),
      ),
      body: switch (state) {
        ProfileConnectionsInitial() => const SizedBox.shrink(),
        ProfileConnectionsLoading() => const Center(
          child: CircularProgressIndicator(color: AppTheme.primaryBrand),
        ),
        ProfileConnectionsError(:final message) => _buildError(message),
        ProfileConnectionsLoaded() => _buildLoaded(state),
      },
    );
  }

  /// Error state with retry action.
  Widget _buildError(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(message, style: AppTheme.bodyMedium),
          const SizedBox(height: 12),
          ElevatedButton(
            key: const Key('profile_connections_retry_button'),
            onPressed: _loadInitial,
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  /// Loaded list with empty and pagination states.
  Widget _buildLoaded(ProfileConnectionsLoaded state) {
    if (state.users.isEmpty) {
      return Center(
        child: Text(
          'No users found.',
          key: const Key('profile_connections_empty_text'),
          style: AppTheme.bodyMedium,
        ),
      );
    }

    return ListView.builder(
      key: const Key('profile_connections_list_view'),
      controller: _scrollController,
      itemCount: state.users.length + 1,
      itemBuilder: (context, index) {
        if (index == state.users.length) {
          return state.isLoadingMore
              ? const Padding(
                  padding: EdgeInsets.all(16),
                  child: Center(
                    child: CircularProgressIndicator(
                      color: AppTheme.primaryBrand,
                      strokeWidth: 2,
                    ),
                  ),
                )
              : const SizedBox.shrink();
        }
        return ProfileUserListTile(user: state.users[index]);
      },
    );
  }
}
