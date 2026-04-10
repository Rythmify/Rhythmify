import 'package:flutter/material.dart';

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
  final String imagePath;
  final double height;
  final Color color;
}
