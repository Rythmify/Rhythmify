import 'package:flutter/material.dart';
import '../../domain/entities/feed_item.dart';

class FeedCardSideActions extends StatefulWidget {
  final FeedItemEntity item;

  const FeedCardSideActions({super.key, required this.item});

  @override
  State<FeedCardSideActions> createState() => _FeedCardSideActionsState();
}

class _FeedCardSideActionsState extends State<FeedCardSideActions> {
  bool _liked = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      key: const Key('feed_card_side_actions_column'),
      mainAxisSize: MainAxisSize.min,
      children: [
        _ActionButton(
          key: const Key('feed_card_side_actions_like'),
          icon: _liked ? Icons.favorite : Icons.favorite_border,
          label: '${widget.item.track.likeCount + (_liked ? 1 : 0)}',
          color: _liked ? Colors.orange : Colors.white,
          onTap: () => setState(() => _liked = !_liked),
        ),
        const SizedBox(height: 20),
        _ActionButton(
          key: const Key('feed_card_side_actions_comment'),
          icon: Icons.comment_outlined,
          label: '0',
          onTap: () {},
        ),
      ],
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ActionButton({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
    this.color = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      key: const Key('action_button_gesture'),
      onTap: onTap,
      child: Column(
        key: const Key('action_button_column'),
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 4),
          Text(label, style: TextStyle(color: color, fontSize: 12)),
        ],
      ),
    );
  }
}