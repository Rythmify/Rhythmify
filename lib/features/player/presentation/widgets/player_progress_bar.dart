import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/formatters.dart';
import '../providers/player_provider.dart';

/// A seekable progress bar displaying the current playback position and duration.
///
/// This widget allows users to jump to different parts of a track and
/// provides visual feedback on current progress.
///
/// Depends on [playerStateProvider].
class PlayerProgressBar extends ConsumerStatefulWidget {
  const PlayerProgressBar({super.key});

  @override
  ConsumerState<PlayerProgressBar> createState() => _PlayerProgressBarState();
}

class _PlayerProgressBarState extends ConsumerState<PlayerProgressBar> {
  /// Local state to manage smooth dragging without being interrupted by the position stream.
  double? _dragValue;

  @override
  Widget build(BuildContext context) {
    final position = ref.watch(
      playerStateProvider.select((state) => state.position),
    );
    final duration = ref.watch(
      playerStateProvider.select((state) => state.duration),
    );

    final maxDuration = duration.inMilliseconds.toDouble() > 0
        ? duration.inMilliseconds.toDouble()
        : 1.0;

    final currentPos =
        _dragValue ??
        position.inMilliseconds.toDouble().clamp(0.0, maxDuration);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        children: [
          Text(
            '${Formatters.formatDuration(Duration(milliseconds: currentPos.toInt()))}  |  ${Formatters.formatDuration(duration)}',
            key: const Key('player_progress_bar_duration_text'),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
          SliderTheme(
            data: SliderThemeData(
              trackHeight: 4,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
              overlayShape: const RoundSliderOverlayShape(overlayRadius: 20),
              activeTrackColor: AppTheme.primaryBrand,
              inactiveTrackColor: Colors.white.withValues(alpha: 0.3),
            ),
            child: Slider(
              key: const Key('player_progress_bar_slider'),
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
                ref
                    .read(playerStateProvider.notifier)
                    .seek(Duration(milliseconds: value.toInt()));
                setState(() {
                  _dragValue = null;
                });
              },
            ),
          ),
        ],
      ),
    );
  }
}
