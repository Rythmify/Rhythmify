import 'package:flutter/material.dart';
import 'likes_banner_shimmer.dart';
import 'top_track_card_shimmer.dart';
import 'section_header_shimmer.dart';
import 'trending_genre_shimmer.dart';
import 'hot_for_you_shimmer.dart';
import 'playlist_card_shimmer.dart';
import 'station_card_shimmer.dart';

class HomeShimmerScreen extends StatelessWidget {
  const HomeShimmerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const NeverScrollableScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const LikesBannerShimmer(),
          
          // Top Tracks Grid
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 8,
                crossAxisSpacing: 8,
                childAspectRatio: 2.92, // Matching dynamicAspectRatio approx
              ),
              itemCount: 4,
              itemBuilder: (context, index) => const TopTrackCardShimmer(),
            ),
          ),
          
          const SizedBox(height: 16),
          
          const SectionHeaderShimmer(),
          const TrendingGenreShimmer(),
          
          const SectionHeaderShimmer(),
          const HotForYouShimmer(),
          
          const SizedBox(height: 40),
          
          const SectionHeaderShimmer(),
          SizedBox(
            height: 160,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: 5,
              separatorBuilder: (context, index) => const SizedBox(width: 12),
              itemBuilder: (context, index) => const PlaylistCardShimmer(),
            ),
          ),
          
          const SizedBox(height: 30),
          
          const SectionHeaderShimmer(),
          SizedBox(
            height: 200,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: 5,
              separatorBuilder: (context, index) => const SizedBox(width: 12),
              itemBuilder: (context, index) => const StationCardShimmer(),
            ),
          ),
          
          const SectionHeaderShimmer(),
          SizedBox(
            height: 180,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: 5,
              separatorBuilder: (context, index) => const SizedBox(width: 12),
              itemBuilder: (context, index) => const PlaylistCardShimmer(),
            ),
          ),
        ],
      ),
    );
  }
}