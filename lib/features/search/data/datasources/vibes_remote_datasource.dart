import 'package:flutter/material.dart';
import '../../domain/entities/vibes_category.dart';

/// Contract for the vibes/categories remote data source.
abstract class VibesRemoteSource {
  /// Returns the list of all vibe categories shown in the vibes grid.
  Future<List<VibeCategory>> getVibes();
}

/// Mock implementation of [VibesRemoteSource] for the vibes grid.
/// Each [VibeCategory] includes a height and color used to drive the staggered grid layout.
/// Only this file changes at backend integration time.
class VibesRemoteSourceMock implements VibesRemoteSource {
  /// Returns a hardcoded list of vibe categories with a simulated 300ms delay.
  /// Heights are intentionally varied to produce the staggered column effect in the UI.
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
