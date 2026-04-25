// lib/features/playlist/presentation/widgets/playlist_screen_scaffold.dart
//
// Wraps any root-level playlist screen (PlaylistDetailScreen, MixDetailScreen,
// RelatedTracksScreen) with a mini-player at the bottom.
//
// Why needed: these screens use parentNavigatorKey: _rootNavigatorKey in the
// router, so they render above MainAppScaffold. The scaffold's mini-player
// is underneath and never visible. This widget re-adds it locally.
//
// Usage — wrap your Scaffold's body in PlaylistScreenScaffold:
//
//   return PlaylistScreenScaffold(
//     body: Scaffold(
//       backgroundColor: Colors.black,
//       body: ...,
//     ),
//   );

library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../player/presentation/providers/player_provider.dart';
import '../../../player/presentation/widgets/mini_player.dart';

class PlaylistScreenScaffold extends ConsumerWidget {
  const PlaylistScreenScaffold({super.key, required this.child});

  /// The screen's own Scaffold — passed as-is.
  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hasTrack = ref.watch(
      playerStateProvider.select((s) => s.currentTrack != null),
    );

    return Stack(
      children: [
        // The screen itself — fills the whole space
        child,

        // Mini-player pinned to the bottom, only when a track is active
        if (hasTrack)
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: MiniPlayer(onTap: () => context.push('/player')),
          ),
      ],
    );
  }
}
