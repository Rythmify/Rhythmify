import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/presentation/widgets/custom_bottom_sheet.dart';
import '../../../../core/domain/entities/track.dart';
import '../../../../core/presentation/widgets/follow_button.dart';
import '../../../premium/presentation/providers/premium_provider.dart';
import '../../../library/presentation/providers/downloads_provider.dart';

/// A horizontal bar containing interactive engagement metrics and playback controls.
///
/// Displays formatted counts for likes, comments, and reposts. It also includes
/// a primary play/pause button that interacts directly with the [playerStateProvider]
/// to control playback or load the track into the active queue.
///
/// Expects a [track] entity to display accurate engagement numbers and handle playback.

class TrackDetailsSection extends ConsumerWidget {
  final Track track;

  const TrackDetailsSection({super.key, required this.track});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
                  style: AppTheme.bodyMedium.copyWith(color: Colors.white),
                ),
                GestureDetector(
                  key: const Key(
                    'behind_the_track_show_more_description_gesture_detector',
                  ),
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
        // Download Button for Premium Users
        Consumer(
          builder: (context, ref, child) {
            final canDownload = ref.watch(canDownloadProvider);
            if (!canDownload) return const SizedBox.shrink();

            final downloadsState = ref.watch(downloadsProvider);
            final isDownloaded = downloadsState.isDownloaded(track.id);
            final progress = downloadsState.getProgress(track.id);
            final error = downloadsState.getDownloadError(track.id);

            String label = 'Download';
            IconData icon = Icons.download_rounded;
            VoidCallback? onPressed = () =>
                ref.read(downloadsProvider.notifier).downloadTrack(track);

            if (isDownloaded) {
              label = 'Downloaded';
              icon = Icons.download_done_rounded;
              onPressed = null; // Already downloaded
            } else if (progress != null) {
              label = 'Downloading ${(progress * 100).toInt()}%';
              icon = Icons.sync_rounded;
              onPressed = null; // Already in progress
            } else if (error != null) {
              label = 'Retry Download';
              icon = Icons.error_outline_rounded;
              // onPressed remains the same to allow retry
            }

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  OutlinedButton.icon(
                    key: const Key('behind_the_track_download_button'),
                    onPressed: onPressed,
                    icon: progress != null
                        ? SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              value: progress,
                              strokeWidth: 2,
                              color: AppTheme.textPrimary,
                            ),
                          )
                        : Icon(icon, size: 20),
                    label: Text(label),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: isDownloaded
                          ? AppTheme.primaryBrand
                          : AppTheme.textPrimary,
                      side: BorderSide(
                        color: isDownloaded
                            ? AppTheme.primaryBrand
                            : AppTheme.textSecondary,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                    ),
                  ),
                  if (error != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      'Download failed: $error',
                      style: const TextStyle(color: Colors.red, fontSize: 12),
                    ),
                  ],
                  const SizedBox(height: 16),
                ],
              ),
            );
          },
        ),
        if (track.tags.isNotEmpty)
          SizedBox(
            height: 32,
            child: ListView.separated(
              key: const Key('behind_the_track_tags_list_view'),
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
              Expanded(
                child: InkWell(
                  key: Key(
                    'track_details_section_artist_inkwell_${track.userId}',
                  ),
                  onTap: () {
                    context.push('/home/profile/${track.userId}');
                  },
                  borderRadius: BorderRadius.circular(8),
                  highlightColor: Colors.white.withValues(alpha: 0.1),
                  splashColor: Colors.white.withValues(alpha: 0.2),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 24,
                        backgroundColor: AppTheme.perfectGrey,
                        backgroundImage:
                            track.artistPfp != null &&
                                track.artistPfp!.isNotEmpty
                            ? NetworkImage(track.artistPfp!)
                            : null,
                        child:
                            track.artistPfp == null || track.artistPfp!.isEmpty
                            ? const Icon(Icons.person, color: Colors.white)
                            : null,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              track.artist.isNotEmpty
                                  ? track.artist
                                  : "Unknown Artist",
                              style: AppTheme.titleLarge.copyWith(fontSize: 16),
                              overflow: TextOverflow.ellipsis,
                            ),
                            if ((track.artistCity != null &&
                                    track.artistCity!.isNotEmpty) ||
                                (track.artistCountry != null &&
                                    track.artistCountry!.isNotEmpty))
                              Text(
                                [
                                  if (track.artistCity != null &&
                                      track.artistCity!.isNotEmpty)
                                    track.artistCity,
                                  if (track.artistCountry != null &&
                                      track.artistCountry!.isNotEmpty)
                                    track.artistCountry,
                                ].join(', '),
                                style: AppTheme.labelSmall,
                                overflow: TextOverflow.ellipsis,
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),
              FollowButton(
                key: Key('track_details_section_follow_button_${track.userId}'),
                targetUserId: track.userId,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
