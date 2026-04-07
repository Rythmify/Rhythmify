import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import '../../domain/entities/vibes_category.dart';

class VibesGrid extends StatelessWidget {
  const VibesGrid({super.key, required this.vibes, required this.onVibeTap});

  final List<VibeCategory> vibes;
  final void Function(VibeCategory vibe) onVibeTap;

  @override
  Widget build(BuildContext context) {
    return MasonryGridView.count(
      key: const Key('vibes_masonry_grid'),
      crossAxisCount: 2,
      mainAxisSpacing: 10,
      crossAxisSpacing: 10,
      itemCount: vibes.length,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemBuilder: (context, index) {
        final vibe = vibes[index];
        return SizedBox(
          key: Key('vibe_item_${vibe.id}'),
          height: vibe.height,
          child: _VibeCard(vibe: vibe, onTap: () => onVibeTap(vibe)),
        );
      },
    );
  }
}

class _VibeCard extends StatelessWidget {
  const _VibeCard({required this.vibe, required this.onTap});

  final VibeCategory vibe;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      key: Key('vibe_card_${vibe.id}'),
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
              Image.asset(
                vibe.imagePath,
                key: Key('vibe_image_${vibe.id}'),
                fit: BoxFit.cover,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
