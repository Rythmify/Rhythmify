import 'package:flutter/material.dart';
import '../../../../core/domain/entities/track.dart';
import '../../../../core/theme/app_theme.dart';

/// A widget that displays the current track's title and artist.
///
/// It also includes a "Behind this track" button for navigating to detailed
/// track information.
class TrackInfoBox extends StatelessWidget {
  /// The summary metadata of the track to display.
  final Track summary;

  /// Callback to navigate to the detailed track information page.
  final VoidCallback onNavigateBehindTrack;

  const TrackInfoBox({
    super.key,
    required this.summary,
    required this.onNavigateBehindTrack,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          key: const Key('player_track_info_box_details_gesturedetector'),
          onTap: onNavigateBehindTrack,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.6),
              borderRadius: BorderRadius.circular(4),
            ),
            child: RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: '${summary.title}\n',
                    style: AppTheme.titleMedium,
                  ),
                  TextSpan(
                    text: summary.artist,
                    style: AppTheme.titleMedium.copyWith(
                      fontSize: 16,
                      color: AppTheme.semiWhite,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 4),
        GestureDetector(
          key: const Key('player_track_info_box_behind_track_gesturedetector'),
          onTap: onNavigateBehindTrack,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.6),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: const [
                Icon(Icons.music_note, color: AppTheme.semiWhite, size: 16),
                SizedBox(width: 6),
                Text(
                  'Behind this track',
                  style: TextStyle(
                    color: AppTheme.semiWhite,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
