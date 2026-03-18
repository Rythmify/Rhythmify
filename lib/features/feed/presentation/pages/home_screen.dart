import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rythmify/features/feed/presentation/widgets/trending_by_genre.dart';
import 'package:rythmify/features/track_upload/presentation/providers/upload_track_provider.dart';
import 'package:rythmify/features/feed/presentation/widgets/hot_for_you.dart';
import 'package:rythmify/features/feed/presentation/widgets/mixed_for_you.dart';
import 'package:rythmify/features/feed/presentation/widgets/discover_with_stations.dart';
import 'package:rythmify/features/feed/presentation/widgets/more_of_what_you_like.dart';


// Import your entities, models, and widgets (adjust the relative paths if your folder structure differs slightly)
import '../../../../core/domain/entities/track_summary.dart';
import '../../../../core/data/models/track_summary_dto.dart';

//imports for track upload added by hana
import 'package:file_picker/file_picker.dart';
import 'package:just_audio/just_audio.dart';



// 1. Temporary provider to fetch the ENTIRE list of tracks for UI testing
final testAllTracksProvider = FutureProvider<List<TrackSummary>>((ref) async {
  final jsonString = await rootBundle.loadString(
    'assets/mocks/tracks_summary.json',
  );
  final List<dynamic> jsonList = jsonDecode(jsonString);

  // Map the whole JSON array into a list of TrackSummary objects
  return jsonList.map((json) => TrackSummaryDto.fromJson(json)).toList();
});

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 2. Watch the list provider

    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.arrow_circle_up),
            onPressed: () async{
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
                  final player   = AudioPlayer();
                  final detected = await player.setFilePath(picked.path!);
                  duration       = detected ?? Duration.zero;
                  await player.dispose();
                } catch (_) {}

                ref.read(uploadFormProvider.notifier).initDraft(
                  artistId:       'dev_user_001',
                  localAudioPath: picked.path!,
                  duration:       duration,
                  fileName:       picked.name,
                );

                if (context.mounted) context.push('/upload-track');

              } catch (e) {
                // Show exactly what error occurs
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error: $e')),
                  );
                }
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.mail_outline),
            onPressed: () {
              context.push('/home/inbox');
            },
          ),
          IconButton(
            icon: const Icon(Icons.notifications_none),
            onPressed: () {
              context.push('/home/notifications');
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 150),
        children: const [
          SizedBox(height: 16),

          TrendingByGenre(),

          SizedBox(height: 24),

          HotForYouSection(),

          SizedBox(height: 40),

          MixedPlaylistsSection(),

          SizedBox(height: 40),

          DiscoverWithStationsSection(),

          SizedBox(height: 40),

          MoreOfWhatYouLikeSection(),
        ],
      ),
    );
  }
}
