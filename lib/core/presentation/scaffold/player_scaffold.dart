import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../features/player/presentation/widgets/mini_player.dart';
import '../../../features/player/presentation/pages/full_player_page.dart';
import '../../../features/player/presentation/providers/player_provider.dart';

class PlayerScaffold extends ConsumerStatefulWidget {
  final Widget child;

  const PlayerScaffold({super.key, required this.child});

  @override
  ConsumerState<PlayerScaffold> createState() => _PlayerScaffoldState();
}

class _PlayerScaffoldState extends ConsumerState<PlayerScaffold> {
  void _openFullPlayer(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const FullPlayerPage(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final playerState = ref.watch(playerStateProvider);
    final hasTrack = playerState.currentTrack != null;

    return Stack(
      children: [
        // Main App Content
        Positioned.fill(
          bottom: hasTrack ? 60.0 : 0.0, // Leave room for MiniPlayer if there's a track
          child: widget.child,
        ),
        
        // Mini Player
        if (hasTrack)
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            height: 60,
            child: MiniPlayer(
              onTap: () => _openFullPlayer(context),
            ),
          ),
      ],
    );
  }
}
