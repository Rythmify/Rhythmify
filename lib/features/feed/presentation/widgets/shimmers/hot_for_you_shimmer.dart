import 'package:flutter/material.dart';
import '../../../../../core/presentation/widgets/base_shimmer.dart';

class HotForYouShimmer extends StatelessWidget {
  const HotForYouShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: BaseShimmer(
        child: Container(
          height: 120,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              const ShimmerBox(width: 65, height: 70, borderRadius: 8),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const ShimmerBox(width: 150, height: 16),
                    const SizedBox(height: 8),
                    const ShimmerBox(width: 100, height: 12),
                  ],
                ),
              ),
              const ShimmerBox(width: 50, height: 50, shape: BoxShape.circle),
            ],
          ),
        ),
      ),
    );
  }
}
