import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
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
import '../../../../core/error/error_handler.dart';

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

    final homeContent = ListView(
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
              itemBuilder: (context, index) => HomeTopTrackCard(
                track: latestTracks[index],
                allTracks: latestTracks,
                index: index,
              ),
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
    );

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
        child: asyncHome.when(
          data: (_) => homeContent,
          loading: () => const HomeShimmerScreen(),
          error: (error, stack) {
            // If we have cached/previous data, continue showing it even on error.
            if (asyncHome.hasValue) return homeContent;

            // If initial load fails due to connectivity, show the specific placeholder.
            if (_isConnectivityError(error)) {
              return const _NoInternetPlaceholder();
            }

            // Fallback for other types of errors.
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: 48,
                      color: AppTheme.textSecondary,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      ErrorHandler.getFriendlyMessage(error),
                      textAlign: TextAlign.center,
                      style: AppTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

/// Helper to detect if a [DioException] is related to connectivity.
bool _isConnectivityError(dynamic error) {
  if (error is DioException) {
    return error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.sendTimeout ||
        error.type == DioExceptionType.receiveTimeout ||
        error.type == DioExceptionType.connectionError ||
        error.error is SocketException;
  }
  return false;
}

/// A placeholder displayed when the home screen fails to load due to no internet.
///
/// It features a "wifi off" icon, a descriptive message, and a button that
/// navigates the user to the Downloads page in the Library tab.
class _NoInternetPlaceholder extends StatelessWidget {
  const _NoInternetPlaceholder();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: Container(
        // Centers the content while allowing enough height for RefreshIndicator to work.
        height: MediaQuery.of(context).size.height - 200,
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.wifi_off_rounded,
              size: 80,
              color: AppTheme.textSecondary,
            ),
            const SizedBox(height: 24),
            Text(
              'No internet connection',
              style: AppTheme.titleLarge.copyWith(
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
             Text(
              'Please check your connection or listen to your downloaded music.',
              style: AppTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () => context.go('/library/downloads'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryBrand,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                elevation: 0,
              ),
              child: const Text(
                'Go to Downloads',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
