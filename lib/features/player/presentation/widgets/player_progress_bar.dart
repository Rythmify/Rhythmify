import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/formatters.dart';
import '../providers/player_provider.dart';

class PlayerProgressBar extends ConsumerWidget {
  const PlayerProgressBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    /// Isolates the rapid state changes.
    /// Only this small widget rebuilds every tick.
    final position = ref.watch(playerStateProvider.select((state) => state.position));
    final duration = ref.watch(playerStateProvider.select((state) => state.duration));

    final maxDuration = duration.inMilliseconds.toDouble() > 0 
        ? duration.inMilliseconds.toDouble() 
        : 1.0;
    final currentPos = position.inMilliseconds.toDouble().clamp(0.0, maxDuration);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        children: [
          Text(
            '${Formatters.formatDuration(position)} | ${Formatters.formatDuration(duration)}',
            style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600),
          ),
          SliderTheme(
            data: SliderThemeData(
              trackHeight: 2,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 0),
              overlayShape: const RoundSliderOverlayShape(overlayRadius: 0),
              activeTrackColor: AppTheme.primaryBrand,
              inactiveTrackColor: Colors.white.withValues(alpha: 0.3),
            ),
            child: Slider(
              min: 0,
              max: maxDuration,
              value: currentPos,
              onChanged: (value) {
                ref.read(playerStateProvider.notifier).seek(Duration(milliseconds: value.toInt()));
              },
            ),
          ),
        ],
      ),
    );
  }
}