import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/presentation/widgets/custom_bottom_sheet.dart';

/// A horizontal bar containing interactive engagement metrics and playback controls.
///
/// Displays formatted counts for likes, comments, and reposts. It also includes 
/// a primary play/pause button that interacts directly with the [playerStateProvider] 
/// to control playback or load the track into the active queue.
///
/// Expects a [track] entity to display accurate engagement numbers and handle playback.

class TrackDetailsSection extends StatelessWidget {
  final dynamic track;

  const TrackDetailsSection({super.key, required this.track});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (track.description != null && track.description!.isNotEmpty) ...[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  track.description!,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppTheme.bodyMedium.copyWith(
                    color: Colors.white,
                  ),
                ),
                GestureDetector(
                  key: const Key('behind_the_track_show_more_description_gesture_detector'),
                  onTap: () {
                    CustomBottomSheet.show(
                      context: context,
                      title: "Description",
                      content: track.description!,
                    );
                  },
                  child: Text(
                    "Show more",
                    style: AppTheme.labelLarge.copyWith(
                      color: AppTheme.link,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
        ],
        if (track.tags.isNotEmpty)
          SizedBox(
            height: 32,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              scrollDirection: Axis.horizontal,
              itemCount: track.tags.length,
              separatorBuilder: (context, index) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                return Container(
                  key: Key('behind_the_track_tag_${track.tags[index]}'),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.perfectGrey,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    "#${track.tags[index]}",
                    style: AppTheme.titleLarge.copyWith(
                      color: AppTheme.fadedWhite,
                      fontSize: 15,
                    ),
                  ),
                );
              },
            ),
          ),
        const SizedBox(height: 24),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: [
              const CircleAvatar(
                radius: 24,
                backgroundImage: AssetImage('assets/images/track_1.jpg'), 
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "User Display Name",
                      style: AppTheme.titleLarge.copyWith(fontSize: 16),
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      "user city and country",
                      style: AppTheme.labelSmall,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              OutlinedButton(
                key: const Key('behind_the_track_follow_outlined_button'),
                onPressed: () {},
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppTheme.textSecondary),
                  shape: const StadiumBorder(),
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                ),
                child: const Text(
                  "Follow",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}