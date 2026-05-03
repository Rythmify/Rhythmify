import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:rythmify/features/track/domain/usecases/toggle_like.dart';
import 'package:rythmify/features/track/domain/usecases/toggle_repost.dart';
import 'package:rythmify/features/track/presentation/providers/track_dependency_providers.dart';
import 'package:rythmify/features/track/presentation/providers/track_interaction_provider.dart';

class MockToggleLike extends Mock implements ToggleLike {}

class MockToggleRepost extends Mock implements ToggleRepost {}

void main() {
  late ProviderContainer container;
  late MockToggleLike mockToggleLike;
  late MockToggleRepost mockToggleRepost;

  setUp(() {
    mockToggleLike = MockToggleLike();
    mockToggleRepost = MockToggleRepost();

    container = ProviderContainer(
      overrides: [
        toggleLikeUseCaseProvider.overrideWithValue(mockToggleLike),
        toggleRepostUseCaseProvider.overrideWithValue(mockToggleRepost),
      ],
    );
  });

  tearDown(() {
    container.dispose();
  });

  group('TrackInteractionNotifier', () {
    test('handleToggleLike calls ToggleLike usecase', () async {
      when(() => mockToggleLike.call(any(), any())).thenAnswer((_) async {});

      final notifier = container.read(trackInteractionProvider);

      await notifier.handleToggleLike('track-123', false);

      verify(() => mockToggleLike.call('track-123', true)).called(1);
    });

    test('handleToggleLike handles errors gracefully', () async {
      when(
        () => mockToggleLike.call(any(), any()),
      ).thenThrow(Exception('Error'));

      final notifier = container.read(trackInteractionProvider);

      await expectLater(
        notifier.handleToggleLike('track-123', false),
        completes,
      );
    });

    test('handleToggleRepost calls ToggleRepost usecase', () async {
      when(() => mockToggleRepost.call(any(), any())).thenAnswer((_) async {});

      final notifier = container.read(trackInteractionProvider);

      await notifier.handleToggleRepost('track-123', true);

      verify(() => mockToggleRepost.call('track-123', false)).called(1);
    });

    test('handleToggleRepost handles errors gracefully', () async {
      when(
        () => mockToggleRepost.call(any(), any()),
      ).thenThrow(Exception('Error'));

      final notifier = container.read(trackInteractionProvider);

      await expectLater(
        notifier.handleToggleRepost('track-123', true),
        throwsA(isA<Exception>()),
      );
    });
  });
}
