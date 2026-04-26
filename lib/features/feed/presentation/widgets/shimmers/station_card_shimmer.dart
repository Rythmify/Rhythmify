import 'package:flutter/material.dart';
import '../../../../../core/presentation/widgets/base_shimmer.dart';

class StationCardShimmer extends StatelessWidget {
  const StationCardShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        BaseShimmer(
          child: ShimmerBox(width: 160, height: 155, borderRadius: 8),
        ),
        SizedBox(height: 6),
        BaseShimmer(child: ShimmerBox(width: 120, height: 12)),
      ],
    );
  }
}
