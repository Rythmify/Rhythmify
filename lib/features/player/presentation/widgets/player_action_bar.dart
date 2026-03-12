import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/utils/formatters.dart';
import '../../../track/presentation/providers/track_provider.dart';
import '../../../../core/theme/app_theme.dart'; 

class PlayerActionBar extends ConsumerWidget {
  final String trackId;
  const PlayerActionBar({super.key, required this.trackId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final trackAsync = ref.watch(trackDetailsProvider(trackId));

    return Container(
      color: AppTheme.background,
      padding: const EdgeInsets.only(bottom: 36, top: 25, left: 16, right: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              const Icon(Icons.favorite_border, color: Colors.white),
              const SizedBox(width: 6),
              trackAsync.when(
                data: (track) => Text(
                  Formatters.formatCount(track.likeCount),
                  style: AppTheme.bodyNormal,
                ),
                loading: () => const SizedBox(
                  width: 10,
                  height: 10,
                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)),
                error: (a,b) => const Text('0', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ],
            
          ),
          const Icon(Icons.chat_bubble_outline, color: Colors.white),
          const Icon(Icons.share_outlined, color: Colors.white),
          const Icon(Icons.playlist_play, color: Colors.white),
          const Icon(Icons.more_vert, color: Colors.white),
        ],
      ),
    );
  }
}