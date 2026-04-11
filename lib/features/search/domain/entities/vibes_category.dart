import 'package:flutter/material.dart';

/// Represents a single vibe/genre category card in the vibes grid.
class VibeCategory {
  const VibeCategory({
    required this.id,
    required this.title,
    required this.imagePath,
    required this.height,
    required this.color,
  });

  final String id;
  final String title;

  /// Local asset path for the category's background image.
  final String imagePath;

  /// Card height used to drive the staggered column layout in the vibes grid.
  final double height;

  /// Accent color displayed as an overlay or background tint on the card.
  final Color color;
}
