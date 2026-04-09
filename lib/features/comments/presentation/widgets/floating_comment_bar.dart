import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../player/presentation/providers/player_provider.dart';
import '../providers/floating_comments_provider.dart';
import '../providers/track_comments_notifier.dart';
import '../widgets/floating_comment.dart';

class FloatingCommentBar extends ConsumerStatefulWidget {
  const FloatingCommentBar({super.key});

  @override
  ConsumerState<FloatingCommentBar> createState() => _FloatingCommentBarState();
}

class _FloatingCommentBarState extends ConsumerState<FloatingCommentBar>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  
  String? _currentCommentPfp;
  String _currentCommentText = ""; 
  int _lastTimestamp = -1;

  final TextEditingController _commentController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutBack,
    );

    _commentController.addListener(() {
      setState(() {
        _hasText = _commentController.text.trim().isNotEmpty;
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _commentController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _postComment(String trackId) {
    if (_commentController.text.trim().isEmpty) return;

    final position = ref.read(playerStateProvider).position;

    ref
        .read(trackCommentsProvider(trackId).notifier)
        .postNewComment(_commentController.text, position.inSeconds);

    _commentController.clear();
    _focusNode.unfocus();
  }

  void _appendEmoji(String emoji) {
    final currentText = _commentController.text;
    _commentController.value = TextEditingValue(
      text: currentText + emoji,
      selection: TextSelection.collapsed(offset: currentText.length + emoji.length),
    );
    _focusNode.requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    final playerState = ref.watch(playerStateProvider);
    final trackId = playerState.currentTrack?.id;

    if (trackId == null) return const SizedBox.shrink();

    final floatingCommentsAsync = ref.watch(floatingCommentsProvider(trackId));
    final currentSecond = playerState.position.inSeconds;

    if (currentSecond != _lastTimestamp) {
      _lastTimestamp = currentSecond;
      floatingCommentsAsync.whenData((commentsMap) {
        if (commentsMap.containsKey(currentSecond)) {
          setState(() {
            _currentCommentPfp = commentsMap[currentSecond]!.pfp; 
            _currentCommentText = commentsMap[currentSecond]!.text; 
          });
          
          _controller.forward(from: 0).then((_) {
            Future.delayed(const Duration(seconds: 2), () {
              if (mounted) _controller.reverse();
            });
          });
        }
      });
    }

    return Stack(
      alignment: Alignment.center,
      clipBehavior: Clip.none,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Container(
            height: 50,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.6),
              borderRadius: BorderRadius.circular(25),
              border: Border.all(color: Colors.white.withValues(alpha: 0.5)),
            ),
            child: Row(
              children: [
                const SizedBox(width: 16),
                Expanded(
                  child: TextField(
                    controller: _commentController,
                    focusNode: _focusNode,
                    style: AppTheme.bodyNormal,
                    decoration: InputDecoration(
                      hintText: 'Drop a comment...',
                      hintStyle: AppTheme.bodyNormal,
                      border: InputBorder.none,
                      isDense: true,
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                ),
                if (_hasText)
                  GestureDetector(
                    onTap: () => _postComment(trackId),
                    child: Container(
                      padding: const EdgeInsets.all(9),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.send, color: Colors.black, size: 20),
                    ),
                  )
                else
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      GestureDetector(
                        onTap: () => _appendEmoji('🔥'),
                        child: const Text('🔥', style: TextStyle(fontSize: 20)),
                      ),
                      const SizedBox(width: 24),
                      GestureDetector(
                        onTap: () => _appendEmoji('👏'),
                        child: const Text('👏', style: TextStyle(fontSize: 20)),
                      ),
                      const SizedBox(width: 24),
                      GestureDetector(
                        onTap: () => _appendEmoji('🥺'),
                        child: const Text('🥺', style: TextStyle(fontSize: 20)),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ),
        
        Positioned(
          bottom: 200, 
          left: 32, 
          right: 32,
          child: Align(
            alignment: Alignment.center,
            child: ScaleTransition(
              scale: _animation,
              child: FloatingComment(
                imageUrl: _currentCommentPfp,
                text: _currentCommentText,
              ),
            ),
          ),
        ),
      ],
    );
  }
}