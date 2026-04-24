// import 'package:flutter/material.dart';
// import '../../domain/entities/feed_item.dart';

// class DiscoverFeedCardSideActions extends StatefulWidget {
//   final DiscoverFeedItemEntity item;

//   const DiscoverFeedCardSideActions({super.key, required this.item});

//   @override
//   State<DiscoverFeedCardSideActions> createState() =>
//       _DiscoverFeedCardSideActionsState();
// }

// class _DiscoverFeedCardSideActionsState
//     extends State<DiscoverFeedCardSideActions> {
//   bool _liked = false;

//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       mainAxisSize: MainAxisSize.min,
//       children: [
//         _ActionButton(
//           icon: _liked ? Icons.favorite : Icons.favorite_border,
//           label: '${widget.item.track.likeCount + (_liked ? 1 : 0)}',
//           color: _liked ? Colors.orange : Colors.white,
//           onTap: () => setState(() => _liked = !_liked),
//         ),
//         const SizedBox(height: 20),
//         _ActionButton(icon: Icons.comment_outlined, label: '0', onTap: () {}),
//       ],
//     );
//   }
// }

// class _ActionButton extends StatelessWidget {
//   final IconData icon;
//   final String label;
//   final Color color;
//   final VoidCallback onTap;

//   const _ActionButton({
//     required this.icon,
//     required this.label,
//     required this.onTap,
//     this.color = Colors.white,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       onTap: onTap,
//       child: Column(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           Icon(icon, color: color, size: 28),
//           const SizedBox(height: 4),
//           Text(label, style: TextStyle(color: color, fontSize: 12)),
//         ],
//       ),
//     );
//   }
// }
