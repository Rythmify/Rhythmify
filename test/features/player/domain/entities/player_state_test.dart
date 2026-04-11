import 'package:flutter_test/flutter_test.dart';
import 'package:rythmify/core/domain/entities/track.dart';
import 'package:rythmify/features/player/domain/entities/player_state.dart';

void main() {
  final tTrack = Track(
    id: 'track-1',
    userId: 'user-1',
    title: 'Test Track',
    artist: 'Artist',
    audioUrl: 'http://example.com/audio.mp3',
    duration: const Duration(minutes: 3),
    createdAt: DateTime(2023, 10, 15),
  );

  group('AppPlayerState', () {
    test('initial state should have correct default values', () {
      const state = AppPlayerState();

      expect(state.status, PlayerStatus.initial);
      expect(state.currentTrack, isNull);
      expect(state.position, Duration.zero);
      expect(state.bufferedPosition, Duration.zero);
      expect(state.duration, Duration.zero);
      expect(state.isShuffleModeEnabled, false);
      expect(state.loopMode, 'off');
    });

    test('copyWith should replace fields properly', () {
      const state = AppPlayerState();

      final updatedState = state.copyWith(
        status: PlayerStatus.playing,
        currentTrack: tTrack,
        position: const Duration(seconds: 10),
        bufferedPosition: const Duration(seconds: 20),
        duration: const Duration(minutes: 3),
        isShuffleModeEnabled: true,
        loopMode: 'all',
      );

      expect(updatedState.status, PlayerStatus.playing);
      expect(updatedState.currentTrack, tTrack);
      expect(updatedState.position, const Duration(seconds: 10));
      expect(updatedState.bufferedPosition, const Duration(seconds: 20));
      expect(updatedState.duration, const Duration(minutes: 3));
      expect(updatedState.isShuffleModeEnabled, true);
      expect(updatedState.loopMode, 'all');
    });

    test('copyWith should retain old values if not provided', () {
      final state = AppPlayerState(
        status: PlayerStatus.playing,
        currentTrack: tTrack,
        position: const Duration(seconds: 10),
      );

      final updatedState = state.copyWith(status: PlayerStatus.paused);

      expect(updatedState.status, PlayerStatus.paused);
      expect(updatedState.currentTrack, tTrack);
      expect(updatedState.position, const Duration(seconds: 10));
      expect(updatedState.bufferedPosition, state.bufferedPosition);
    });

    test('props should contain all fields', () {
      const state = AppPlayerState();
      expect(state.props.length, 7);
      expect(
        state.props,
        containsAll([
          state.status,
          state.currentTrack,
          state.position,
          state.bufferedPosition,
          state.duration,
          state.isShuffleModeEnabled,
          state.loopMode,
        ]),
      );
    });
  });
}
