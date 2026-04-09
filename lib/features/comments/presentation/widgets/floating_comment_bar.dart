import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../player/presentation/providers/player_provider.dart';
import '../providers/floating_comments_provider.dart';
import 'floating_comment.dart';

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
  int _lastTimestamp = -1;

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
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
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
            _currentCommentPfp = commentsMap[currentSecond];
          });
          _controller.forward(from: 0).then((_) {
            Future.delayed(const Duration(seconds: 1), () {
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
                  child: Text(
                    'Drop a comment...',
                    key: const Key('comments_comment_prompt_text'),
                    style: AppTheme.bodyNormal,
                  ),
                ),
                Text(
                  '🔥',
                  key: const Key('comments_fire_emoji_text'),
                  style: const TextStyle(fontSize: 20),
                ),
                const SizedBox(width: 24),
                Text(
                  '👏',
                  key: const Key('comments_clap_emoji_text'),
                  style: const TextStyle(fontSize: 20),
                ),
                const SizedBox(width: 24),
                Text(
                  '🥺',
                  key: const Key('comments_pleading_emoji_text'),
                  style: const TextStyle(fontSize: 20),
                ),
              ],
            ),
          ),
        ),
        Positioned(
          top: 200,
          child: ScaleTransition(
            scale: _animation,
            child: FloatingComment(imageUrl: _currentCommentPfp),
          ),
        ),
      ],
    );
  }
}
