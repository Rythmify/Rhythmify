import '../../domain/entities/vibes_category.dart';
import 'package:flutter/material.dart';

class VibesDto {
  // Fixed height and color pools — cycled by index since /genres returns no visuals.
  // TODO: replace imagePath fallback with cover_image from endpoint when added.
  static const List<double> _heights = [130, 160, 120, 150, 140, 170, 125, 155];
  static const List<Color> _colors = [
    Color(0xFFE91E63),
    Color(0xFF9C27B0),
    Color(0xFF3F51B5),
    Color(0xFF009688),
    Color(0xFFFF5722),
    Color(0xFF607D8B),
    Color(0xFFFF9800),
    Color(0xFF4CAF50),
  ];

  static VibeCategory parseVibeCategory(Map<String, dynamic> json, int index) {
    return VibeCategory(
      id: json['id'] as String,
      title: json['name'] as String,
      imagePath: json['cover_image'] as String? ?? '',
      height: _heights[index % _heights.length],
      color: _colors[index % _colors.length],
    );
  }

  static List<VibeCategory> parseVibeCategoryList(Map<String, dynamic> json) {
    final list = json['data'] as List? ?? [];
    return list
        .asMap()
        .entries
        .map((e) => parseVibeCategory(e.value as Map<String, dynamic>, e.key))
        .toList();
  }
}
