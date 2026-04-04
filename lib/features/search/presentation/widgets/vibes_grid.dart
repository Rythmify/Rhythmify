import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import '../../domain/entities/vibes_category.dart';

/// ─────────────────────────────────────────────
/// VIBES GRID (Masonry)
/// ─────────────────────────────────────────────
///

class VibesGrid extends StatelessWidget {
  const VibesGrid({super.key, required this.vibes, required this.onVibeTap});

  final List<VibeCategory> vibes;
  final void Function(VibeCategory vibe) onVibeTap;

  @override
  Widget build(BuildContext context) {
    return MasonryGridView.count(
      crossAxisCount: 2,
      mainAxisSpacing: 10,
      crossAxisSpacing: 10,
      itemCount: vibes.length,

      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),

      itemBuilder: (context, index) {
        final vibe = vibes[index];

        return SizedBox(
          height: vibe.height,
          child: _VibeCard(vibe: vibe, onTap: () => onVibeTap(vibe)),
        );
      },
    );
  }
}

/// ─────────────────────────────────────────────
/// CARD
/// ─────────────────────────────────────────────
class _VibeCard extends StatelessWidget {
  const _VibeCard({required this.vibe, required this.onTap});

  final VibeCategory vibe;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: vibe.color, width: 1.5),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: Stack(
            fit: StackFit.expand,
            children: [
              /// Background image
              Image.asset(vibe.imagePath, fit: BoxFit.cover),

              /// Title
              // Positioned(
              //   left: 12,
              //   bottom: 12,
              //   right: 8,
              //   child: Text(
              //     vibe.title,
              //     style: const TextStyle(
              //       color: Colors.white,
              //       fontSize: 16,
              //       fontWeight: FontWeight.bold,
              //       height: 1.1,
              //     ),
              //   ),
              // ),
            ],
          ),
        ),
      ),
    );
  }
}
