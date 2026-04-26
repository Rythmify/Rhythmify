import 'package:flutter/material.dart';
import '../../../../../core/presentation/widgets/base_shimmer.dart';

class PlaylistCardShimmer extends StatelessWidget {
  const PlaylistCardShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        BaseShimmer(
          child: ShimmerBox(width: 140, height: 140, borderRadius: 1),
        ),
        SizedBox(height: 8),
        BaseShimmer(child: ShimmerBox(width: 100, height: 12)),
      ],
    );
  }
}
