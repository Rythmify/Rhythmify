import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/formatters.dart';
import '../providers/player_provider.dart';

class PlayerProgressBar extends ConsumerStatefulWidget {
  const PlayerProgressBar({super.key});

  @override
  ConsumerState<PlayerProgressBar> createState() => _PlayerProgressBarState();
}

class _PlayerProgressBarState extends ConsumerState<PlayerProgressBar> {
  double? _dragValue;

  @override
  Widget build(BuildContext context) {
    // Watch the global position and duration
    final position = ref.watch(playerStateProvider.select((state) => state.position));
    final duration = ref.watch(playerStateProvider.select((state) => state.duration));

    final maxDuration = duration.inMilliseconds.toDouble() > 0 
        ? duration.inMilliseconds.toDouble() 
        : 1.0;

    // Use the local drag value if it exists, otherwise use the stream position
    final currentPos = _dragValue ?? position.inMilliseconds.toDouble().clamp(0.0, maxDuration);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        children: [
          Text(
            '${Formatters.formatDuration(Duration(milliseconds: currentPos.toInt()))}  |  ${Formatters.formatDuration(duration)}',
            style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600),
          ),
          SliderTheme(
            data: SliderThemeData(
              trackHeight: 4,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6), // Added small thumb for better visual feedback
              overlayShape: const RoundSliderOverlayShape(overlayRadius: 20),
              activeTrackColor: AppTheme.primaryBrand,
              inactiveTrackColor: Colors.white.withValues(alpha: 0.3),
            ),
            child: Slider(
              min: 0,
              max: maxDuration,
              value: currentPos,
              onChangeStart: (value) {
                setState(() {
                  _dragValue = value;
                });
              },
              onChanged: (value) {
                setState(() {
                  _dragValue = value;
                });
              },
              onChangeEnd: (value) {
                // Only trigger the actual seek when the user releases their finger
                ref.read(playerStateProvider.notifier).seek(Duration(milliseconds: value.toInt()));
                setState(() {
                  _dragValue = null; // Resume following the stream
                });
              },
            ),
          ),
        ],
      ),
    );
  }
}
