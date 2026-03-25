import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/track_provider.dart';
import '../../../../core/theme/app_theme.dart';
import '../widgets/fans_leaderboard.dart';
import '../widgets/track_details_section.dart';
import '../widgets/track_action_bar.dart';
import '../widgets/track_info_header.dart';

/// A page that displays detailed information and engagement data for a specific track.
///
/// This page acts as the main scaffold, fetching data via [trackDetailsProvider] 
/// and orchestrating the [TrackInfoHeader], [TrackActionBar], [TrackDetailsSection], 
/// and [FansLeaderboard] widgets to provide a comprehensive view of the track.
///
/// Requires a [trackId] to fetch the relevant track data.

class BehindTheTrackPage extends ConsumerWidget {
  final String trackId;

  const BehindTheTrackPage({super.key, required this.trackId});

  @override
  Widget build(BuildContext context, WidgetRef ref){
    final trackAsync = ref.watch(trackDetailsProvider(trackId));

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: trackAsync.when(
        data: (track) => SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(vertical: 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 10),
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
                          shape:   const CircleBorder(),
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

                const SizedBox(height: 15),
                TrackInfoHeader(track: track),

                const SizedBox(height: 16),
                TrackActionBar(track: track),

                const SizedBox(height: 14),
                TrackDetailsSection(track: track),

                const SizedBox(height: 35),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: FansLeaderboard(),
                ),
                const SizedBox(height: 155),
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
}