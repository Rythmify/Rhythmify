import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../providers/fan_leaderboard_provider.dart';

/// [FansLeaderboard] displays a ranked list of the most active fans for a track.
///
/// It features a toggle interface to switch between "All Time" (overall)
/// and "Last 7 Days" (7d) periods.
class FansLeaderboard extends ConsumerWidget {
  final String trackId;

  const FansLeaderboard({super.key, required this.trackId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final period = ref.watch(fanLeaderboardPeriodProvider(trackId));
    final leaderboardAsync = ref.watch(fanLeaderboardProvider(trackId));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text("Fans Leaderboard", style: AppTheme.titleLarge),
            const SizedBox(width: 8),
            const Icon(
              key: Key('fans_leaderboard_info_icon'),
              Icons.info_outline,
              size: 18,
              color: AppTheme.textSecondary,
            ),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          width: double.infinity,
          decoration: const BoxDecoration(
            color: AppTheme.perfectGrey,
            borderRadius: BorderRadius.all(Radius.circular(32)),
          ),
          child: Column(
            children: [
              const SizedBox(height: 24),
              // Segmented Control (Toggle)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Container(
                  height: 48,
                  decoration: BoxDecoration(
                    color: AppTheme.background,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Stack(
                    children: [
                      // The Animated Sliding Indicator
                      AnimatedAlign(
                        alignment: period == LeaderboardPeriod.overall
                            ? Alignment.centerLeft
                            : Alignment.centerRight,
                        duration: const Duration(milliseconds: 200),
                        curve: Curves.easeInOut,
                        child: FractionallySizedBox(
                          widthFactor: 0.5,
                          child: Container(
                            margin: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: AppTheme.textPrimary,
                                width: 0.8,
                              ),
                              borderRadius: BorderRadius.circular(20),
                              color: AppTheme.perfectGrey,
                            ),
                          ),
                        ),
                      ),
                      // The Clickable Labels
                      Row(
                        children: [
                          _buildSegmentText(
                            ref,
                            LeaderboardPeriod.overall,
                            LeaderboardPeriod.overall.label,
                          ),
                          _buildSegmentText(
                            ref,
                            LeaderboardPeriod.sevenDays,
                            LeaderboardPeriod.sevenDays.label,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                "Top fans based on listening activity",
                style: AppTheme.labelSmall,
              ),
              const SizedBox(height: 24),

              // Content based on state
              leaderboardAsync.when(
                data: (leaderboard) {
                  if (leaderboard.items.isEmpty) {
                    return const Padding(
                      padding: EdgeInsets.symmetric(vertical: 40.0),
                      child: Text(
                        "No fan activity yet",
                        style: TextStyle(color: AppTheme.textSecondary),
                      ),
                    );
                  }

                  return ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 8,
                    ),
                    itemCount: leaderboard.items.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 16),
                    itemBuilder: (context, index) {
                      final item = leaderboard.items[index];
                      return _buildListenerCard(context, item);
                    },
                  );
                },
                loading: () => const Padding(
                  padding: EdgeInsets.symmetric(vertical: 40.0),
                  child: CircularProgressIndicator(),
                ),
                error: (err, stack) => Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 40.0,
                    horizontal: 24,
                  ),
                  child: Text(
                    "Error loading leaderboard: $err",
                    style: const TextStyle(color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSegmentText(
    WidgetRef ref,
    LeaderboardPeriod value,
    String label,
  ) {
    return Expanded(
      child: GestureDetector(
        key: Key('fans_leaderboard_${value.value}_segment_gesture_detector'),
        onTap: () {
          ref.read(fanLeaderboardPeriodProvider(trackId).notifier).state =
              value;
        },
        behavior: HitTestBehavior.opaque,
        child: Container(
          alignment: Alignment.center,
          child: Text(
            label,
            style: AppTheme.labelLarge.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildListenerCard(BuildContext context, dynamic item) {
    return InkWell(
      onTap: () {
        context.push('/home/profile/${item.userId}');
      },
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4.0),
        child: Row(
          children: [
            // 1. Rank
            SizedBox(
              width: 24,
              child: Text(
                '${item.rank}',
                style: AppTheme.bodyNormal.copyWith(color: AppTheme.semiWhite),
              ),
            ),
            const SizedBox(width: 8),
            // 2. Circular Profile Picture
            CircleAvatar(
              radius: 18,
              backgroundColor: AppTheme.surface,
              backgroundImage: item.profilePicture != null
                  ? NetworkImage(item.profilePicture!)
                  : null,
              child: item.profilePicture == null
                  ? const Icon(
                      Icons.person,
                      size: 18,
                      color: AppTheme.textSecondary,
                    )
                  : null,
            ),
            const SizedBox(width: 12),
            // 3. Display Name
            Expanded(
              child: Row(
                children: [
                  Flexible(
                    child: Text(
                      item.displayName,
                      style: AppTheme.bodyNormal,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
            // 4. Play Count
            Text(
              '${item.playCount} plays',
              style: AppTheme.labelSmall.copyWith(color: AppTheme.primaryBrand),
            ),
          ],
        ),
      ),
    );
  }
}
