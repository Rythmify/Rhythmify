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

import '../../../../core/domain/entities/track.dart';
import '../../../../core/data/models/track_dto.dart';

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
      appBar: AppBar(
        title: const Text('Home'),
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.arrow_circle_up),
            onPressed: () {
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
