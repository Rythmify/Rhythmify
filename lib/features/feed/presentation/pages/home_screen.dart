import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; 
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Import your entities, models, and widgets (adjust the relative paths if your folder structure differs slightly)
import '../../../../core/domain/entities/track_summary.dart';
import '../../../../core/data/models/track_summary_dto.dart';
import '../../../../features/track/presentation/widgets/track_card.dart';

// 1. Temporary provider to fetch the ENTIRE list of tracks for UI testing
final testAllTracksProvider = FutureProvider<List<TrackSummary>>((ref) async {
  final jsonString = await rootBundle.loadString('assets/mocks/tracks_summary.json');
  final List<dynamic> jsonList = jsonDecode(jsonString);
  
  // Map the whole JSON array into a list of TrackSummary objects
  return jsonList.map((json) => TrackSummaryDto.fromJson(json)).toList();
});

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 2. Watch the list provider
    final feedState = ref.watch(testAllTracksProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.arrow_circle_up),
            onPressed: () {},
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
      body: feedState.when(
        data: (tracks) {
          // 3. Use ListView.builder to stack the cards perfectly.
          return ListView.builder(
            padding: const EdgeInsets.only(top: 20.0), // Space at the top
            itemCount: 4, // <-- We only want to show 4 tracks right now (change to tracks.length to show all)
            itemBuilder: (context, index) {
              return TrackCard(track: tracks[index]);
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err', style: const TextStyle(color: Colors.red))),
      ),
    );
  }
}