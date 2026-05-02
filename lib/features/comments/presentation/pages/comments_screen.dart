import '../../../player/presentation/providers/player_provider.dart';
import '../../domain/repositories/comment_repository.dart';
import '../../../authentication/presentation/providers/auth_provider.dart';
import '../../../authentication/presentation/providers/auth_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/domain/entities/track.dart';
import '../providers/comment_replies_notifier.dart';
import '../providers/track_comments_notifier.dart';
import '../../../../core/utils/time_utils.dart';
import '../../../../core/theme/app_theme.dart';
import '../widgets/comment_reply_card.dart';
import 'package:flutter/material.dart';
import '../widgets/comment_card.dart';

import '../../../track/presentation/providers/track_sync_provider.dart';

/// A full-screen page displaying the complete list of comments for a track.
///
/// This Presentation layer page manages the primary comment feed, rendering
/// [CommentCard]s and nested [CommentReplyCard]s. It integrates with
/// [TrackCommentsNotifier] for pagination, sorting, and posting root comments.
class CommentsScreen extends ConsumerStatefulWidget {
  /// The [Track] entity these comments belong to.
  final Track track;

  /// Creates a [CommentsScreen] for the specified [track].
  const CommentsScreen({super.key, required this.track});

  @override
  ConsumerState<CommentsScreen> createState() => _CommentsScreenState();
}

class _CommentsScreenState extends ConsumerState<CommentsScreen> {
  final TextEditingController _commentController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _focusNode = FocusNode();

  String? _replyingToCommentId;
  String? _replyingToUsername;
  final Set<String> _expandedCommentIds = {};

  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _commentController.addListener(() {
      setState(() {
        _hasText = _commentController.text.trim().isNotEmpty;
      });
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final notifier = ref.read(trackCommentsProvider(widget.track.id).notifier);
      notifier.setInitialTrack(widget.track);
      // Force a fresh fetch from the server every time the screen opens
      notifier.fetchComments(refresh: true);
    });
  }

  @override
  void dispose() {
    _commentController.dispose();
    _scrollController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      ref.read(trackCommentsProvider(widget.track.id).notifier).fetchNextPage();
    }
  }

  void _toggleReplies(String commentId) {
    setState(() {
      if (_expandedCommentIds.contains(commentId)) {
        _expandedCommentIds.remove(commentId);
      } else {
        _expandedCommentIds.add(commentId);
      }
    });
  }

  void _cancelReply() {
    setState(() {
      _replyingToCommentId = null;
      _replyingToUsername = null;
    });
    _focusNode.unfocus();
    _commentController.clear();
  }

  void _showSortBottomSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.grey[900],
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Consumer(
          builder: (context, ref, child) {
            final state = ref.watch(trackCommentsProvider(widget.track.id));
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 16),
                _buildSortOption(
                  context,
                  ref,
                  'Newest',
                  CommentSortType.newest,
                  state.sortType,
                ),
                _buildSortOption(
                  context,
                  ref,
                  'Oldest',
                  CommentSortType.oldest,
                  state.sortType,
                ),
                _buildSortOption(
                  context,
                  ref,
                  'Track Time',
                  CommentSortType.timestamp,
                  state.sortType,
                ),
                const SizedBox(height: 24),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildSortOption(
    BuildContext context,
    WidgetRef ref,
    String label,
    CommentSortType type,
    CommentSortType currentType,
  ) {
    final isSelected = type == currentType;
    return ListTile(
      key: Key('comments_sort_option_${type.name}_list_tile'),
      title: Text(label, style: TextStyle(color: Colors.white)),
      trailing: isSelected
          ? const Icon(Icons.check_circle, color: Colors.white)
          : null,
      onTap: () {
        ref
            .read(trackCommentsProvider(widget.track.id).notifier)
            .toggleSort(type);
        Navigator.pop(context);
      },
    );
  }

  void _postComment() {
    if (_commentController.text.trim().isEmpty) return;

    final position = ref.read(playerStateProvider).position;

    if (_replyingToCommentId != null) {
      final parentId = _replyingToCommentId!;

      // Post a reply
      ref
          .read(commentRepliesProvider(parentId).notifier)
          .postReply(
            widget.track.id,
            _commentController.text,
            position.inSeconds,
          );

      // Automatically expand the replies section
      //so the user can see their new reply
      setState(() {
        _expandedCommentIds.add(parentId);
      });
    } else {
      // Post a top-level comment
      ref
          .read(trackCommentsProvider(widget.track.id).notifier)
          .postNewComment(_commentController.text, position.inSeconds);
    }

    _cancelReply();
  }

  @override
  Widget build(BuildContext context) {
    final syncedTrack = ref.watch(syncedTrackProvider(widget.track));
    final state = ref.watch(trackCommentsProvider(widget.track.id));
    final playerPosition = ref.watch(
      playerStateProvider.select((s) => s.position),
    );

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.all(9.0),
          child: CircleAvatar(
            backgroundColor: Colors.grey[900],
            child: IconButton(
              key: const Key('comments_close_icon_button'),
              icon: const Icon(Icons.close, color: Colors.white, size: 20),
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ),
        titleSpacing: 8,
        title: Text(
          '${syncedTrack.commentCount} Comments',
          style: AppTheme.titleMedium.copyWith(fontSize: 18),
        ),
        actions: [
          IconButton(
            key: const Key('comments_sort_icon_button'),
            icon: const Icon(Icons.tune, color: Colors.white),
            onPressed: _showSortBottomSheet,
          ),
        ],
      ),
      body: Column(
        children: [
          _buildTrackHeader(syncedTrack),
          Expanded(
            child: CustomScrollView(
              controller: _scrollController,
              slivers: [
                SliverList(
                  delegate: SliverChildBuilderDelegate((context, index) {
                    if (index >= state.comments.length) {
                      return state.isFetchingNextPage
                          ? const Padding(
                              padding: EdgeInsets.all(16.0),
                              child: Center(child: CircularProgressIndicator()),
                            )
                          : const SizedBox.shrink();
                    }
                    final comment = state.comments[index];
                    final isExpanded = _expandedCommentIds.contains(comment.id);

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CommentCard(
                          key: Key('comments_card_${comment.id}'),
                          comment: comment,
                          isExpanded: isExpanded,
                          onLike: () => ref
                              .read(
                                trackCommentsProvider(widget.track.id).notifier,
                              )
                              .toggleLike(comment.id),
                          onReply: () {
                            setState(() {
                              _replyingToCommentId = comment.id;
                              _replyingToUsername = comment.userDisplayName;
                            });
                            _focusNode.requestFocus();
                          },
                          onMore: () {
                            showModalBottomSheet(
                              context: context,
                              builder: (c) => const SizedBox(height: 200),
                            );
                          },
                          onShowReplies: () => _toggleReplies(comment.id),
                        ),

                        if (isExpanded)
                          Consumer(
                            builder: (context, ref, child) {
                              final repliesState = ref.watch(
                                commentRepliesProvider(comment.id),
                              );

                              if (repliesState.isFetchingNextPage &&
                                  repliesState.comments.isEmpty) {
                                return const Padding(
                                  padding: EdgeInsets.only(
                                    left: 48.0,
                                    bottom: 8.0,
                                    top: 8.0,
                                  ),
                                  child: SizedBox(
                                    height: 16,
                                    width: 16,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  ),
                                );
                              }

                              return Column(
                                children: repliesState.comments.map((reply) {
                                  return CommentReplyCard(
                                    key: Key('comments_reply_card_${reply.id}'),
                                    reply: reply,
                                    onLike: () => ref
                                        .read(
                                          commentRepliesProvider(
                                            comment.id,
                                          ).notifier,
                                        )
                                        .toggleLike(reply.id),
                                    onMore: () {
                                      /* Handle more */
                                    },
                                  );
                                }).toList(),
                              );
                            },
                          ),
                      ],
                    );
                  }, childCount: state.comments.length + 1),
                ),
              ],
            ),
          ),
          _buildBottomInput(playerPosition),
        ],
      ),
    );
  }

  Widget _buildTrackHeader(Track syncedTrack) {
    final isNetworkImage =
        syncedTrack.artworkUrl.startsWith('http') ||
        syncedTrack.artworkUrl.startsWith('https');

    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Column(
        children: [
          Row(
            children: [
              const SizedBox(width: 4),
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.4),
                    width: 1,
                  ),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(5),
                  child: isNetworkImage
                      ? Image.network(
                          syncedTrack.artworkUrl,
                          width: 47,
                          height: 47,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              Container(
                                color: Colors.grey,
                                width: 47,
                                height: 47,
                              ),
                        )
                      : Image.asset(
                          syncedTrack.artworkUrl,
                          width: 47,
                          height: 47,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              Container(
                                color: Colors.grey,
                                width: 47,
                                height: 47,
                              ),
                        ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      syncedTrack.title,
                      style: AppTheme.bodyNormal.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      syncedTrack.artist,
                      style: AppTheme.labelSmall.copyWith(
                        color: Colors.white70,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),

          const Divider(color: Colors.white24, height: 25),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const SizedBox(width: 6),

                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2A2A2A),
                      shape: BoxShape.circle,
                    ),
                    child: const Text('❤️‍🔥', style: TextStyle(fontSize: 14)),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    '${syncedTrack.likeCount}  people liked that track',
                    style: AppTheme.labelSmall.copyWith(
                      color: Colors.white70,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 10),
          const Divider(color: Colors.white24, height: 1),
        ],
      ),
    );
  }

  Widget _buildBottomInput(Duration playerPosition) {
    final authState = ref.watch(authProvider);

    String? pfpUrl;
    if (authState is AuthAuthenticated) {
      pfpUrl = authState.user.avatarUrl;
    }
    return Container(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 8,
        bottom: 8 + MediaQuery.of(context).padding.bottom,
      ),
      decoration: const BoxDecoration(
        color: Colors.black,
        border: Border(top: BorderSide(color: Colors.white12)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_replyingToUsername != null)
            Padding(
              padding: const EdgeInsets.only(
                bottom: 8.0,
                left: 4.0,
                right: 4.0,
              ),
              child: Row(
                children: [
                  Text(
                    'Replying to ',
                    style: AppTheme.labelSmall.copyWith(color: Colors.white70),
                  ),
                  Text(
                    _replyingToUsername!,
                    style: AppTheme.labelSmall.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  GestureDetector(
                    key: const Key('comments_cancel_reply_gesture_detector'),
                    onTap: _cancelReply,
                    child: const Icon(
                      Icons.close,
                      size: 16,
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),
          Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: Colors.grey[800],
                backgroundImage: pfpUrl != null && pfpUrl.isNotEmpty
                    ? (pfpUrl.startsWith('http') || pfpUrl.startsWith('https')
                          ? NetworkImage(pfpUrl) as ImageProvider
                          : AssetImage(pfpUrl))
                    : null,
                child: pfpUrl == null || pfpUrl.isEmpty
                    ? const Icon(Icons.person, color: Colors.white, size: 18)
                    : null,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  key: const Key('comments_input_textfield'),
                  controller: _commentController,
                  focusNode: _focusNode,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    isDense: true,
                    hintText: 'Add a comment...',
                    hintStyle: const TextStyle(color: AppTheme.semiWhite),
                    filled: true,
                    fillColor: Colors.grey[900],
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 9,
                    ),
                    suffixIconConstraints: const BoxConstraints(
                      minHeight: 0,
                      minWidth: 0,
                    ),

                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide: BorderSide.none,
                    ),
                    suffixIcon: Padding(
                      padding: const EdgeInsets.only(right: 14.0),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            TimeUtils.formatTrackTimestamp(
                              playerPosition.inSeconds,
                            ),
                            style: const TextStyle(
                              color: AppTheme.semiWhite,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              if (_hasText) ...[
                const SizedBox(width: 8),
                GestureDetector(
                  key: const Key('comments_post_gesture_detector'),
                  onTap: _postComment,
                  child: Container(
                    padding: const EdgeInsets.all(9),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.send,
                      color: Colors.black,
                      size: 20,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
