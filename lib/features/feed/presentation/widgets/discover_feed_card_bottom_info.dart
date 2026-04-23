// import 'dart:ui';
// import 'package:flutter/material.dart';
// import '../../domain/entities/feed_item.dart';
// import 'feed_card_play_button.dart';

// class DiscoverFeedCardBottomInfo extends StatelessWidget {
//   final DiscoverFeedItemEntity item;
//   final bool showProgress;
//   const DiscoverFeedCardBottomInfo({
//     super.key,
//     required this.item,
//     this.showProgress = false,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return ClipRect(
//       child: BackdropFilter(
//         filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
//         child: Container(
//           padding: const EdgeInsets.only(left: 8, right: 8, top: 5, bottom: 20),
//           width: double.infinity,
//           decoration: BoxDecoration(
//             borderRadius: BorderRadius.circular(15),
//             color: Colors.white.withOpacity(0.12),
//             border: Border(
//               top: BorderSide(color: Colors.white.withOpacity(0.15), width: 1),
//             ),
//           ),
//           child: Row(
//             crossAxisAlignment: CrossAxisAlignment.center,
//             children: [
//               const SizedBox(width: 12),
//               Expanded(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   mainAxisSize: MainAxisSize.min,
//                   children: [
//                     const SizedBox(height: 2),
//                     Text(
//                       item.track.title,
//                       style: const TextStyle(
//                         color: Colors.white,
//                         fontSize: 20,
//                         fontWeight: FontWeight.bold,
//                       ),
//                       maxLines: 1,
//                       overflow: TextOverflow.ellipsis,
//                     ),
//                     const SizedBox(height: 6),
//                     Row(
//                       children: [
//                         const CircleAvatar(
//                           radius: 14,
//                           backgroundColor: Colors.white24,
//                           child: Icon(
//                             Icons.person,
//                             color: Colors.white54,
//                             size: 14,
//                           ),
//                         ),
//                         const SizedBox(width: 8),
//                         Text(
//                           item.track.uploaderUsername,
//                           style: const TextStyle(
//                             color: Colors.white70,
//                             fontSize: 14,
//                           ),
//                         ),
//                         const SizedBox(width: 10),
//                         _FollowButton(),
//                       ],
//                     ),
//                   ],
//                 ),
//               ),
//               const SizedBox(width: 12),
//               FeedCardPlayCircle(showProgress: showProgress, size: 50),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

// class _FollowButton extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return OutlinedButton(
//       onPressed: () {},
//       style: OutlinedButton.styleFrom(
//         foregroundColor: Colors.white,
//         side: const BorderSide(color: Colors.white60),
//         padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
//         minimumSize: Size.zero,
//         tapTargetSize: MaterialTapTargetSize.shrinkWrap,
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
//       ),
//       child: const Text('Follow', style: TextStyle(fontSize: 12)),
//     );
//   }
// }
