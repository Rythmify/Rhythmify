import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rythmify/features/feed/presentation/widgets/trending_by_genre.dart';
import 'package:rythmify/features/feed/presentation/widgets/hot_for_you.dart';

// Import your entities, models, and widgets (adjust the relative paths if your folder structure differs slightly)
import '../../../../core/domain/entities/track_summary.dart';
import '../../../../core/data/models/track_summary_dto.dart';

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
          IconButton(icon: const Icon(Icons.arrow_circle_up), onPressed: () {}),
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
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            SizedBox(height: 16),

            TrendingByGenre(),

            SizedBox(height: 24),

            HotForYouSection(),

            SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
