import 'package:flutter/material.dart';
import '../../domain/entities/vibes_category.dart';

abstract class VibesRemoteSource {
  Future<List<VibeCategory>> getVibes();
}

//this is for the vibes grid itself
class VibesRemoteSourceMock implements VibesRemoteSource {
  @override
  Future<List<VibeCategory>> getVibes() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return const [
      VibeCategory(
        id: 'hiphop',
        title: 'Hip Hop & Rap',
        imagePath: 'assets/images/vibes_hiphop.jpeg',
        height: 150,
        color: Color(0xFF7B4FD4),
      ),
      VibeCategory(
        id: 'electronic',
        title: 'Electronic',
        imagePath: 'assets/images/vibes_electronic.jpeg',
        height: 230,
        color: Color(0xFFeb34d2),
      ),
      VibeCategory(
        id: 'pop',
        title: 'Pop',
        imagePath: 'assets/images/vibes_pop.jpeg',
        height: 250,
        color: Color(0xFFebff36),
      ),
      VibeCategory(
        id: 'rnb',
        title: 'R&B',
        imagePath: 'assets/images/vibes_rb.jpeg',
        height: 70,
        color: Color(0xFF2bf8ff),
      ),
      VibeCategory(
        id: 'party',
        title: 'Party',
        imagePath: 'assets/images/vibes_party.jpeg',
        height: 160,
        color: Color(0xFFfa9b0f),
      ),
      VibeCategory(
        id: 'chill',
        title: 'Chill',
        imagePath: 'assets/images/vibes_chill.jpeg',
        height: 75,
        color: Color(0xFF2bf8ff),
      ),
      VibeCategory(
        id: 'techno',
        title: 'Techno',
        imagePath: 'assets/images/vibes_techno.jpeg',
        height: 250,
        color: Color(0xFFeb34d2),
      ),
      VibeCategory(
        id: 'workout',
        title: 'Workout',
        imagePath: 'assets/images/vibes_workout.jpeg',
        height: 170,
        color: Color(0xFF6eff9e),
      ),
    ];
  }
}
