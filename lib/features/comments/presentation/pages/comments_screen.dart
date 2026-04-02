import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/domain/entities/track.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/time_utils.dart';
import '../../../player/presentation/providers/player_provider.dart';
import '../providers/track_comments_notifier.dart';
import '../../domain/repositories/comment_repository.dart';
import '../widgets/comment_card.dart';
import '../widgets/comment_reply_card.dart';
import '../providers/comment_replies_notifier.dart';

class CommentsScreen extends ConsumerStatefulWidget {
  final Track track;

  const CommentsScreen({super.key, required this.track});

  @override
  ConsumerState<CommentsScreen> createState() => _CommentsScreenState();
}

class _CommentsScreenState extends ConsumerState<CommentsScreen> {
  final TextEditingController _commentController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  
  // NEW: Focus node to control the keyboard
  final FocusNode _focusNode = FocusNode(); 
  
  // NEW: State for tracking replies
  String? _replyingToCommentId;
  String? _replyingToUsername;
  final Set<String> _expandedCommentIds = {};

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _commentController.dispose();
    _scrollController.dispose();
    _focusNode.dispose(); // Don't forget to dispose
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      ref.read(trackCommentsProvider(widget.track.id).notifier).fetchNextPage();
    }
  }

  // NEW: Helper to toggle reply visibility
  void _toggleReplies(String commentId) {
    setState(() {
      if (_expandedCommentIds.contains(commentId)) {
        _expandedCommentIds.remove(commentId);
      } else {
        _expandedCommentIds.add(commentId);
      }
    });
  }

  // NEW: Helper to cancel a pending reply
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
                _buildSortOption(context, ref, 'Newest', CommentSortType.newest, state.sortType),
                _buildSortOption(context, ref, 'Oldest', CommentSortType.oldest, state.sortType),
                _buildSortOption(context, ref, 'Top', CommentSortType.trackTime, state.sortType),
                const SizedBox(height: 24),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildSortOption(BuildContext context, WidgetRef ref, String label, CommentSortType type, CommentSortType currentType) {
    final isSelected = type == currentType;
    return ListTile(
      title: Text(label, style: TextStyle(color: isSelected ? AppTheme.primaryBrand : Colors.white)),
      trailing: isSelected ? const Icon(Icons.check, color: AppTheme.primaryBrand) : null,
      onTap: () {
        ref.read(trackCommentsProvider(widget.track.id).notifier).toggleSort(type);
        Navigator.pop(context);
      },
    );
  }

  void _postComment() {
    if (_commentController.text.trim().isEmpty) return;
    
    final position = ref.read(playerStateProvider).position;
    
    if (_replyingToCommentId != null) {
      // Post a reply
      ref.read(commentRepliesProvider(_replyingToCommentId!).notifier).postReply(
        widget.track.id,
        _commentController.text,
        position.inSeconds,
      );
    } else {
      // Post a top-level comment
      ref.read(trackCommentsProvider(widget.track.id).notifier).postNewComment(
        _commentController.text,
        position.inSeconds,
      );
    }

    _cancelReply(); // Reset state and close keyboard
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(trackCommentsProvider(widget.track.id));
    final playerPosition = ref.watch(playerStateProvider.select((s) => s.position));

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        titleSpacing: 0,
        title: Text(
          '${widget.track.commentCount} Comments',
          style: AppTheme.titleMedium.copyWith(fontSize: 18),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.tune, color: Colors.white),
            onPressed: _showSortBottomSheet,
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: CustomScrollView(
              controller: _scrollController,
              slivers: [
                SliverToBoxAdapter(
                  child: _buildTrackHeader(),
                ),
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      if (index >= state.comments.length) {
                        return state.isFetchingNextPage 
                            ? const Padding(padding: EdgeInsets.all(16.0), child: Center(child: CircularProgressIndicator()))
                            : const SizedBox.shrink();
                      }
                      final comment = state.comments[index];
                      final isExpanded = _expandedCommentIds.contains(comment.id);

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CommentCard(
                            comment: comment,
                            onLike: () => ref.read(trackCommentsProvider(widget.track.id).notifier).toggleLike(comment.id),
                            onReply: () {
                              setState(() {
                                _replyingToCommentId = comment.id;
                                _replyingToUsername = comment.userDisplayName;
                              });
                              _focusNode.requestFocus(); // Opens keyboard
                            },
                            onMore: () {
                              showModalBottomSheet(context: context, builder: (c) => const SizedBox(height: 200));
                            },
                            onShowReplies: () => _toggleReplies(comment.id),
                          ),
                          
                          // NEW: Render replies if expanded
                          if (isExpanded)
                            Consumer(
                              builder: (context, ref, child) {
                                final repliesState = ref.watch(commentRepliesProvider(comment.id));
                                
                                if (repliesState.isFetchingNextPage && repliesState.comments.isEmpty) {
                                  return const Padding(
                                    padding: EdgeInsets.only(left: 48.0, bottom: 8.0, top: 8.0),
                                    child: SizedBox(height: 16, width: 16, child: CircularProgressIndicator(strokeWidth: 2)),
                                  );
                                }

                                return Column(
                                  children: repliesState.comments.map((reply) {
                                    return CommentReplyCard(
                                      reply: reply,
                                      onLike: () => ref.read(commentRepliesProvider(comment.id).notifier).toggleLike(reply.id),
                                      onMore: () { /* Handle more */ },
                                    );
                                  }).toList(),
                                );
                              },
                            ),
                        ],
                      );
                    },
                    childCount: state.comments.length + 1,
                  ),
                ),
              ],
            ),
          ),
          _buildBottomInput(playerPosition),
        ],
      ),
    );
  }

  Widget _buildTrackHeader() {
    // ... (Keep your exact existing _buildTrackHeader implementation)
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: Image.network(
                  widget.track.artworkUrl,
                  width: 50,
                  height: 50,
                  fit: BoxFit.cover,
                  errorBuilder: (a,b,c) => Container(color: Colors.grey, width: 50, height: 50),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(widget.track.artist, style: AppTheme.labelSmall.copyWith(color: Colors.white70)),
                    Text(widget.track.title, style: AppTheme.bodyNormal.copyWith(fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.favorite_border, size: 16, color: Colors.white70),
                  const SizedBox(width: 4),
                  Text(widget.track.likeCount.toString(), style: AppTheme.labelSmall.copyWith(color: Colors.white70)),
                ],
              ),
              Row(
                children: [
                  const Icon(Icons.comment_outlined, size: 16, color: Colors.white70),
                  const SizedBox(width: 4),
                  Text(widget.track.commentCount.toString(), style: AppTheme.labelSmall.copyWith(color: Colors.white70)),
                ],
              ),
            ],
          ),
          const Divider(color: Colors.white12, height: 32),
        ],
      ),
    );
  }

  Widget _buildBottomInput(Duration playerPosition) {
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
          // NEW: Reply banner
          if (_replyingToUsername != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 8.0, left: 4.0, right: 4.0),
              child: Row(
                children: [
                  Text('Replying to ', style: AppTheme.labelSmall.copyWith(color: Colors.white70)),
                  Text(_replyingToUsername!, style: AppTheme.labelSmall.copyWith(fontWeight: FontWeight.bold)),
                  const Spacer(),
                  GestureDetector(
                    onTap: _cancelReply,
                    child: const Icon(Icons.close, size: 16, color: Colors.white70),
                  )
                ],
              ),
            ),
          Row(
            children: [
              const CircleAvatar(
                radius: 18,
                backgroundColor: Colors.grey,
                child: Icon(Icons.person, color: Colors.white),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: _commentController,
                  focusNode: _focusNode, // NEW: Attach the focus node
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'Add a comment...',
                    hintStyle: const TextStyle(color: Colors.white54),
                    filled: true,
                    fillColor: Colors.grey[900],
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide: BorderSide.none,
                    ),
                    suffixIcon: Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            TimeUtils.formatTrackTimestamp(playerPosition.inSeconds),
                            style: TextStyle(color: AppTheme.primaryBrand, fontWeight: FontWeight.bold),
                          ),
                          IconButton(
                            icon: const Icon(Icons.send, color: AppTheme.primaryBrand),
                            onPressed: _postComment,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}