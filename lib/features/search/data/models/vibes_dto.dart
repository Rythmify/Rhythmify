import '../../domain/entities/vibes_category.dart';
import 'package:flutter/material.dart';

class VibesDto {
  // Fixed height and color pools — cycled by index since /genres returns no visuals.
  static const List<double> _heights = [150, 230, 250, 100, 160, 75, 250, 170];
  static const List<Color> _colors = [
    Color.fromARGB(255, 233, 245, 10),
    Color(0xFF9C27B0),
    Color(0xFF3F51B5),
    Color.fromARGB(255, 15, 255, 231),
    Color(0xFFFF5722),
    Color(0xFF607D8B),
    Color(0xFFFF9800),
    Color.fromARGB(255, 255, 15, 167),
  ];
  static const Map<String, String> _images = {
    'hip-hop & rap': 'assets/images/vibes_2.jpeg',
    'electronic': 'assets/images/vibes_1.jpeg',
    'ambient': 'assets/images/vibes_pop.jpeg',
    'r&b / soul': 'assets/images/vibes_6.jpeg',
    'indie': 'assets/images/vibes_3.jpeg',
    'lo-fi': 'assets/images/vibes_4.jpeg',
    'synth-pop': 'assets/images/vibes_techno.jpeg',
    'jazz': 'assets/images/vibes_5.jpeg',
  };

  static VibeCategory parseVibeCategory(Map<String, dynamic> json, int index) {
    final name = json['name'] as String;
    final image =
        _images[name.toLowerCase()] ?? 'assets/images/placeholder.png';
    return VibeCategory(
      id: json['id'] as String,
      title: name,
      imagePath: image,
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
