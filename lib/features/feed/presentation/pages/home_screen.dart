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

// 1. Temporary provider to fetch the ENTIRE list of tracks for UI testing
final testAllTracksProvider = FutureProvider<List<Track>>((ref) async {
  final jsonString = await rootBundle.loadString(
    'assets/mocks/tracks_summary.json',
  );
  final List<dynamic> jsonList = jsonDecode(jsonString);

  // Map the whole JSON array into a list of Track objects
  return jsonList.map((json) => TrackDto.fromJson(json)).toList();
});

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      key: const Key('home_scaffold'), //  Screen key
      appBar: AppBar(
        key: const Key('home_app_bar'), // AppBar key
        title: const Text('Home'),
        centerTitle: false,
        actions: [
          IconButton(
            key: const Key('home_upload_track_icon_button'),
            icon: const Icon(Icons.arrow_circle_up),

            onPressed: () async {
              try {
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

                ref
                    .read(uploadFormProvider.notifier)
                    .initDraft(
                      artistId: 'dev_user_001',
                      localAudioPath: picked.path!,
                      duration: duration,
                      fileName: picked.name,
                    );

                if (context.mounted) context.push('/upload-track');
              } catch (e) {
                // Show exactly what error occurs
                if (context.mounted) {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text('Error: $e')));
                }
              }
            },
          ),
          IconButton(
            key: const Key('home_inbox_icon_button'),
            icon: const Icon(Icons.mail_outline),
            onPressed: () {
              context.push('/home/inbox');
            },
          ),
          IconButton(
            key: const Key('home_notifications_icon_button'),
            icon: const Icon(Icons.notifications_none),
            onPressed: () {
              context.push('/home/notifications');
            },
          ),
        ],
      ),
      body: ListView(
        key: const Key('home_scroll_view'), // ✅ Scrollable area
        padding: const EdgeInsets.only(bottom: 150),
        children: [
          const SizedBox(height: 16),
          TrendingByGenre(),
          const SizedBox(height: 24),
          HotForYouSection(),
          const SizedBox(height: 40),
          MixedPlaylistsSection(),
          const SizedBox(height: 40),
          DiscoverWithStationsSection(),
          const SizedBox(height: 40),
          MoreOfWhatYouLikeSection(),
        ],
      ),
    );
  }
}
