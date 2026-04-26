import 'package:flutter/material.dart';
import '../../../../../core/presentation/widgets/base_shimmer.dart';

class TopTrackCardShimmer extends StatelessWidget {
  const TopTrackCardShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return const BaseShimmer(
      child: ShimmerBox(
        height: 48,
        borderRadius: 12,
      ),
    );
  }
}
