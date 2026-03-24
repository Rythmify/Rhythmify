import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/track_provider.dart';
import '../../../player/presentation/providers/player_provider.dart';
import '../../../player/domain/entities/player_state.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/presentation/widgets/custom_bottom_sheet.dart';
import '../widgets/fans_leaderboard.dart';

class BehindTheTrackPage extends ConsumerWidget {
  final String trackId;

  const BehindTheTrackPage({super.key, required this.trackId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final trackAsync = ref.watch(trackDetailsProvider(trackId));
    final playerState = ref.watch(playerStateProvider);
    final isPlaying = playerState.status == PlayerStatus.playing;
    final isThisTrack = playerState.currentTrack?.id == trackId;

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: trackAsync.when(
        data: (track) => SafeArea(
          child: SingleChildScrollView(
            // Removed horizontal padding here
            padding: const EdgeInsets.symmetric(vertical: 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 10),

                // Top Navigation Bar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        key: const Key('behind_the_track_back_icon_button'),
                        icon: const Icon(
                          Icons.arrow_back,
                          color: AppTheme.appBarItems,
                        ),
                        onPressed: () => Navigator.pop(context),
                        style: IconButton.styleFrom(
                          backgroundColor: AppTheme.surface,
                          shape: const CircleBorder(),
                          padding: const EdgeInsets.all(8),
                        ),
                      ),
                      IconButton(
                        key: const Key('behind_the_track_cast_icon_button'),
                        icon: const Icon(
                          Icons.cast,
                          color: AppTheme.appBarItems,
                        ),
                        onPressed: () {},
                        style: IconButton.styleFrom(
                          backgroundColor: AppTheme.surface,
                          shape: const CircleBorder(),
                          padding: const EdgeInsets.all(8),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                //  Track Header Section
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: Colors.grey.withValues(alpha: 0.7),
                            width: 0.8,
                          ),
                          borderRadius: BorderRadius.circular(9),
                          color: Colors.grey[900],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.asset(
                            track.artworkUrl,
                            width: 100,
                            height: 100,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),

                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(track.title, style: AppTheme.titleLarge),
                            const SizedBox(height: 2),
                            Text(
                              track.artist,
                              style: AppTheme.bodyMedium.copyWith(
                                fontSize: 14,
                                color: Colors.white70,
                              ),
                            ),
                            const SizedBox(height: 4),

                            Row(
                              children: [
                                const Icon(
                                  Icons.play_arrow,
                                  size: 20,
                                  color: AppTheme.semiWhite,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  Formatters.formatCount(track.playCount),
                                  style: AppTheme.labelSmall.copyWith(
                                    fontSize: 12,
                                    color: AppTheme.semiWhite,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                const Text(
                                  "•",
                                  style: TextStyle(color: AppTheme.semiWhite),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  Formatters.formatDuration(track.duration),
                                  style: AppTheme.labelSmall.copyWith(
                                    fontSize: 12,
                                    color: AppTheme.semiWhite,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                const Text(
                                  "•",
                                  style: TextStyle(color: AppTheme.semiWhite),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  Formatters.formatDate(
                                    track.releaseDate != null
                                        ? DateTime.tryParse(
                                                track.releaseDate!,
                                              ) ??
                                              track.createdAt
                                        : track.createdAt,
                                  ),
                                  style: AppTheme.labelSmall.copyWith(
                                    fontSize: 12,
                                    color: AppTheme.semiWhite,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Primary Action Bar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    children: [
                      _buildActionButton(
                        Icons.favorite_border,
                        Formatters.formatCount(track.likeCount),
                      ),
                      const SizedBox(width: 20),
                      _buildActionButton(
                        Icons.comment_outlined,
                        Formatters.formatCount(track.commentCount),
                      ),
                      const SizedBox(width: 20),
                      _buildActionButton(
                        Icons.repeat,
                        Formatters.formatCount(track.repostCount),
                      ),
                      const SizedBox(width: 12),
                      const Icon(
                        Icons.more_vert,
                        color: AppTheme.textSecondary,
                      ),
                      const Spacer(),
                      GestureDetector(
                        key: const Key(
                          'behind_the_track_play_pause_gesture_detector',
                        ),
                        onTap: () {
                          if (isThisTrack) {
                            ref
                                .read(playerStateProvider.notifier)
                                .togglePlayPause();
                          } else {
                            ref
                                .read(playerStateProvider.notifier)
                                .loadAndPlayQueue([track]);
                          }
                        },
                        child: Container(
                          width: 52,
                          height: 52,
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            isPlaying && isThisTrack
                                ? Icons.pause
                                : Icons.play_arrow,
                            color: AppTheme.background,
                            size: 36,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 26),

                // Description Section
                if (track.description != null &&
                    track.description!.isNotEmpty) ...[
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

                // Tags Section
                if (track.tags.isNotEmpty)
                  SizedBox(
                    height: 32,
                    child: ListView.separated(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      scrollDirection: Axis.horizontal,
                      itemCount: track.tags.length,
                      separatorBuilder: (context, index) =>
                          const SizedBox(width: 8),
                      itemBuilder: (context, index) {
                        return Container(
                          key: Key('behind_the_track_tag_${track.tags[index]}'),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: const Color.fromARGB(
                              255,
                              104,
                              69,
                              131,
                            ).withValues(alpha: 0.7),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Text(
                            "#${track.tags[index]}",
                            style: AppTheme.titleLarge.copyWith(
                              color: Colors.white,
                              fontSize: 15,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                const SizedBox(height: 24),

                // Profile Row
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    children: [
                      const CircleAvatar(
                        radius: 24,
                        backgroundImage: AssetImage(
                          'assets/images/track_1.jpg',
                        ), // change to user profile
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "User Display Name",
                              style: AppTheme.titleLarge.copyWith(fontSize: 16),
                            ),
                            Text(
                              "user city and country",
                              style: AppTheme.labelSmall,
                            ),
                          ],
                        ),
                      ),
                      OutlinedButton(
                        key: const Key(
                          'behind_the_track_follow_outlined_button',
                        ),
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
                const SizedBox(height: 40),

                //  Interactive Section Card (Leaderboard)
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: FansLeaderboard(),
                ),

                const SizedBox(height: 155), // Space for player
              ],
            ),
          ),
        ),
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppTheme.primaryBrand),
        ),
        error: (err, stack) => Center(
          child: Text('Error: $err', style: const TextStyle(color: Colors.red)),
        ),
      ),
    );
  }

  Widget _buildActionButton(IconData icon, String value) {
    return Row(
      children: [
        Icon(icon, color: AppTheme.textPrimary, size: 24),
        const SizedBox(width: 8),
        Text(
          value,
          style: AppTheme.labelLarge.copyWith(
            color: AppTheme.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
