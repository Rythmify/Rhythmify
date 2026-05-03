import 'package:flutter_test/flutter_test.dart';
import 'package:rythmify/features/player/domain/entities/player_state.dart';
import 'package:rythmify/core/domain/entities/track.dart';

void main() {
  final tTrack = Track(
    id: '1',
    userId: 'u1',
    title: 'Test Track',
    artist: 'Test Artist',
    audioUrl: 'https://test.com/audio.mp3',
    duration: const Duration(minutes: 3),
    createdAt: DateTime.now(),
  );

  group('AppPlayerState', () {
    test('should support value equality', () {
      expect(const AppPlayerState(), const AppPlayerState());
    });

    test('copyWith should return a copy with updated values', () {
      const state = AppPlayerState();
      final updatedState = state.copyWith(
        status: PlayerStatus.playing,
        currentTrack: tTrack,
        position: const Duration(seconds: 10),
      );

      expect(updatedState.status, PlayerStatus.playing);
      expect(updatedState.currentTrack, tTrack);
      expect(updatedState.position, const Duration(seconds: 10));
      // Other fields should remain default
      expect(updatedState.isShuffleModeEnabled, false);
    });

    test('props should contain all fields', () {
      final state = AppPlayerState(
        status: PlayerStatus.playing,
        currentTrack: tTrack,
        position: const Duration(seconds: 10),
        bufferedPosition: const Duration(seconds: 5),
        duration: const Duration(seconds: 100),
        isShuffleModeEnabled: true,
        loopMode: 'one',
        queueIndex: 1,
      );

      expect(state.props, [
        PlayerStatus.playing,
        tTrack,
        const Duration(seconds: 10),
        const Duration(seconds: 5),
        const Duration(seconds: 100),
        true,
        'one',
        1,
      ]);
    });
  });
}
