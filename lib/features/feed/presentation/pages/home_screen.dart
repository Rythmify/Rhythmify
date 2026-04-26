import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rythmify/features/feed/presentation/widgets/trending_by_genre.dart';
import 'package:rythmify/features/feed/presentation/widgets/hot_for_you.dart';
import 'package:rythmify/features/feed/presentation/widgets/mixed_for_you.dart';
import 'package:rythmify/features/feed/presentation/widgets/discover_with_stations.dart';
import 'package:rythmify/features/feed/presentation/widgets/more_of_what_you_like.dart';
import 'package:rythmify/features/track_upload/presentation/providers/upload_track_provider.dart';
import '../../../../core/domain/entities/track.dart';
import '../../../../core/data/models/track_dto.dart';

//imports for track upload added by hana
import 'package:file_picker/file_picker.dart';
import 'package:just_audio/just_audio.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../library/domain/entities/library_entities.dart';
import '../../../library/presentation/providers/library_providers.dart';
import '../providers/home_providers.dart';
import '../widgets/home_likes_card.dart';
import '../widgets/home_top_track_card.dart';
import '../widgets/shimmers/home_shimmer_screen.dart';

// ── Added for artist name fix ──
import 'package:rythmify/features/authentication/presentation/providers/auth_provider.dart';
import 'package:rythmify/features/authentication/presentation/providers/auth_state.dart';

// 1. Temporary provider to fetch the ENTIRE list of tracks for UI testing
final testAllTracksProvider = FutureProvider<List<Track>>((ref) async {
  final jsonString = await rootBundle.loadString(
    'assets/mocks/tracks_summary.json',
  );
  final List<dynamic> jsonList = jsonDecode(jsonString);

  // Map the whole JSON array into a list of Track objects
  return jsonList.map((json) => TrackDto.fromJson(json)).toList();
});

extension RecentlyPlayedEntryX on RecentlyPlayedEntry {
  Track toTrack() {
    return Track(
      id: trackId,
      userId: userId,
      title: title,
      artist: artistName,
      audioUrl: audioUrl ?? '',
      streamUrl: streamUrl,
      coverImage: artworkUrl,
      duration: Duration(seconds: durationSeconds),
      playCount: playCount,
      isLiked: isLiked,
      isArtistFollowed: isArtistFollowed,
      createdAt: playedAt,
    );
  }
}

/// Home screen of the application feed.
///
/// This screen acts as the main entry point of the user experience after login.
/// It is part of the **Presentation Layer** and is responsible for displaying
/// multiple personalized and discovery-based music sections such as trending tracks,
/// curated playlists, and recommended content.
///
/// It also provides user actions such as:
/// - Uploading a new track
/// - Navigating to inbox
/// - Navigating to notifications
///
/// This widget interacts with:
/// - Riverpod providers (state management)
/// - Use cases indirectly via providers
/// - File picker and audio processing utilities
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  /// Builds the UI of the Home screen.
  ///
  /// This method constructs the main scaffold containing:
  /// - AppBar with navigation and upload actions
  /// - Scrollable feed composed of multiple music discovery sections
  ///
  /// Parameters:
  /// - [context]: Build context used for navigation and UI rendering
  /// - [ref]: Riverpod reference used to interact with providers
  ///
  /// Returns:
  /// - A fully rendered [Scaffold] widget representing the Home screen UI
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final historyState = ref.watch(historyProvider);
    final latestTracks = historyState.entries
        .take(4)
        .map((e) => e.toTrack())
        .toList();

    final asyncHome = ref.watch(homeDataProvider);

    final screenWidth = MediaQuery.of(context).size.width;
    const crossAxisCount = 2;
    const horizontalPadding = 16.0 * 2;
    const crossAxisSpacing = 8.0;
    final itemWidth =
        (screenWidth - horizontalPadding - crossAxisSpacing) / crossAxisCount;
    final dynamicAspectRatio = itemWidth / 59.6;

    final isLoading = asyncHome.isLoading && asyncHome.value == null;

    return Scaffold(
      key: const Key('home_scaffold'),
      appBar: AppBar(
        key: const Key('home_app_bar'),
        title: const Text('Home'),
        centerTitle: false,

        /// Action buttons for user interactions such as uploading tracks,
        /// opening inbox, and viewing notifications.
        actions: [
          IconButton(
            key: const Key('home_upload_track_icon_button'),
            icon: const Icon(Icons.arrow_circle_up),

            /// Handles audio file selection and prepares it for upload.
            ///
            /// Workflow:
            /// 1. Opens file picker restricted to audio files
            /// 2. Extracts selected file path and metadata
            /// 3. Determines audio duration using local player
            /// 4. Initializes upload draft via Riverpod provider
            /// 5. Navigates to upload screen if successful
            ///
            /// Parameters:
            /// - Uses [context] for navigation and UI feedback
            /// - Uses [ref] to update upload state in presentation layer
            ///
            /// Output:
            /// - Initializes upload state in provider
            /// - Navigates to '/upload-track' route on success
            onPressed: () async {
              final result = await FilePicker.platform.pickFiles(
                type: FileType.audio,
                allowMultiple: false,
              );

              if (result == null || result.files.isEmpty) return;
              final picked = result.files.first;
              if (picked.path == null) return;

              Duration duration = Duration.zero;
              try {
                final player = AudioPlayer();
                final detected = await player.setFilePath(picked.path!);
                duration = detected ?? Duration.zero;
                await player.dispose();
              } catch (_) {}

              // ── Fix: read display name from auth provider ──
              final authState = ref.read(authProvider);
              final displayName = authState is AuthAuthenticated
                  ? authState.user.displayName
                  : 'Your Name';

              ref
                  .read(uploadFormProvider.notifier)
                  .initDraft(
                    artistId: 'dev_user_001',
                    artistName: displayName,
                    localAudioPath: picked.path!,
                    duration: duration,
                    fileName: picked.name,
                  );

              if (context.mounted) {
                context.push('/upload-track');
                // Start audio upload right after navigating
                ref.read(uploadFormProvider.notifier).startAudioUpload();
              }
            },
          ),

          /// Navigates user to inbox/messages screen.
          IconButton(
            key: const Key('home_inbox_icon_button'),
            icon: const Icon(Icons.mail_outline),
            onPressed: () {
              context.push('/home/inbox');
            },
          ),

          /// Navigates user to notifications screen.
          IconButton(
            key: const Key('home_notifications_icon_button'),
            icon: const Icon(Icons.notifications_none),
            onPressed: () {
              context.push('/home/notifications');
            },
          ),
        ],
      ),

      /// Main scrollable feed containing multiple music discovery sections.
      ///
      /// Each section represents a modular UI component responsible for
      /// displaying a specific type of recommendation or content grouping.
      body: RefreshIndicator(
        color: AppTheme.primaryBrand,
        onRefresh: () async {
          ref.invalidate(homeDataProvider);
          ref.invalidate(hotForYouProvider);

          await Future.wait([
            ref.read(homeDataProvider.future),
            ref.read(hotForYouProvider.future),
            ref.read(likesProvider.notifier).load(refresh: true),
            ref.read(historyProvider.notifier).load(refresh: true),
          ]);
        },
        child: isLoading
            ? const HomeShimmerScreen()
            : ListView(
                key: const Key('home_scroll_view'),
                padding: const EdgeInsets.only(bottom: 150),
                physics: const AlwaysScrollableScrollPhysics(),
                children: [
                  const LikesBannerWidget(),

                  if (latestTracks.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 24.0),
                      child: GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: crossAxisCount,
                          mainAxisSpacing: 8,
                          crossAxisSpacing: crossAxisSpacing,
                          childAspectRatio: dynamicAspectRatio,
                        ),
                        itemCount: latestTracks.length,
                        itemBuilder: (context, index) =>
                            HomeTopTrackCard(track: latestTracks[index]),
                      ),
                    ),

                  const SizedBox(height: 4),

                  /// Displays trending tracks grouped by genre.
                  TrendingByGenre(),

                  /// Displays personalized "Hot For You" recommendations.
                  HotForYouSection(),

                  const SizedBox(height: 40),

                  /// Displays mixed playlist recommendations.
                  MixedPlaylistsSection(),

                  const SizedBox(height: 30),

                  /// Displays discovery-based station suggestions.
                  DiscoverWithStationsSection(),

                  //const SizedBox(height: 10),

                  /// Displays additional personalized music suggestions.
                  MoreOfWhatYouLikeSection(),
                ],
              ),
      ),
    );
  }
}
