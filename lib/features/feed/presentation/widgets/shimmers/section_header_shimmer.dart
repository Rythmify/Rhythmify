import 'package:flutter/material.dart';
import '../../../../../core/presentation/widgets/base_shimmer.dart';

class SectionHeaderShimmer extends StatelessWidget {
  const SectionHeaderShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.only(bottom: 6, left: 16, top: 16),
      child: BaseShimmer(
        child: ShimmerBox(
          width: 150,
          height: 20,
        ),
      ),
    );
  }
}
