import 'package:flutter/material.dart';
import '../../../../../core/presentation/widgets/base_shimmer.dart';

class LikesBannerShimmer extends StatelessWidget {
  const LikesBannerShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 5.0),
      child: BaseShimmer(
        child: ShimmerBox(
          height: 64,
          //borderRadius: 12,
        ),
      ),
    );
  }
}
