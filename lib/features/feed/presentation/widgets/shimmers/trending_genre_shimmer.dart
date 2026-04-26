import 'package:flutter/material.dart';
import '../../../../../core/presentation/widgets/base_shimmer.dart';

class TrendingGenreShimmer extends StatelessWidget {
  const TrendingGenreShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Tabs
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: SizedBox(
            height: 32,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              scrollDirection: Axis.horizontal,
              itemCount: 5,
              separatorBuilder: (context, index) => const SizedBox(width: 8),
              itemBuilder: (context, index) => const BaseShimmer(
                child: ShimmerBox(width: 80, height: 32, borderRadius: 24),
              ),
            ),
          ),
        ),
        // Tracks
        SizedBox(
          height: 200,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            scrollDirection: Axis.horizontal,
            itemCount: 2,
            separatorBuilder: (context, index) => const SizedBox(width: 10),
            itemBuilder: (context, index) => Column(
              children: List.generate(
                3,
                (i) => const Padding(
                  padding: EdgeInsets.only(bottom: 8.0),
                  child: BaseShimmer(
                    child: ShimmerBox(width: 300, height: 50, borderRadius: 6),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
