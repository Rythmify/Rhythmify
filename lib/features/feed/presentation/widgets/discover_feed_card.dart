// import 'package:flutter/material.dart';
// import '../../domain/entities/feed_item.dart';
// import 'feed_card_cover.dart';
// import 'discover_feed_card_side_actions.dart';
// import 'discover_feed_card_bottom_info.dart';

// class DiscoverFeedCard extends StatelessWidget {
//   final DiscoverFeedItemEntity item;

//   const DiscoverFeedCard({super.key, required this.item});

//   @override
//   Widget build(BuildContext context) {
//     return Stack(
//       fit: StackFit.expand,
//       children: [
//         FeedCardCover(coverUrl: item.track.coverUrl),
//         const DecoratedBox(
//           decoration: BoxDecoration(
//             gradient: LinearGradient(
//               begin: Alignment.topCenter,
//               end: Alignment.bottomCenter,
//               colors: [Colors.transparent, Color(0xD9000000)],
//               stops: [0.45, 1.0],
//             ),
//           ),
//         ),
//         Positioned(
//           right: 12,
//           bottom: 120,
//           child: DiscoverFeedCardSideActions(item: item),
//         ),
//         Positioned(
//           left: 16,
//           right: 0,
//           bottom: 0,
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               Padding(
//                 padding: const EdgeInsets.only(bottom: 8, left: 4),
//                 child: Text(
//                   item.reason.label,
//                   style: const TextStyle(color: Colors.white70, fontSize: 12),
//                 ),
//               ),
//               DiscoverFeedCardBottomInfo(item: item),
//             ],
//           ),
//         ),
//       ],
//     );
//   }
// }
