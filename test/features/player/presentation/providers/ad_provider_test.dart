import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:rythmify/features/player/presentation/providers/ad_provider.dart';
import 'package:rythmify/features/premium/presentation/providers/premium_provider.dart';
import 'package:fake_async/fake_async.dart';

class MockPremiumNotifier extends PremiumNotifier with Mock {}

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  ProviderContainer createContainer({
    bool isPremium = false,
    bool isInitialized = true,
  }) {
    return ProviderContainer(
      overrides: [
        isPremiumProvider.overrideWithValue(isPremium),
        premiumProvider.overrideWith(
          () => MockPremiumNotifierWrapper(
            PremiumState(isInitialized: isInitialized, subscription: null),
          ),
        ),
      ],
    );
  }

  group('AdNotifier', () {
    test('initial state has trackCount 0 and showAd false', () async {
      final container = createContainer();
      expect(container.read(adProvider).trackCount, 0);
      expect(container.read(adProvider).showAd, false);
    });

    test('incrementTrackCount increments count when not premium', () async {
      final container = createContainer();

      // Wait for build to complete (it's async due to SharedPreferences)
      await container.read(adProvider.notifier).build();

      await container.read(adProvider.notifier).incrementTrackCount();

      expect(container.read(adProvider).trackCount, 1);
    });

    test(
      'incrementTrackCount shows ad and resets count at threshold',
      () async {
        final container = createContainer();
        await container.read(adProvider.notifier).build();

        // Threshold is 5
        for (int i = 0; i < 4; i++) {
          await container.read(adProvider.notifier).incrementTrackCount();
        }
        expect(container.read(adProvider).trackCount, 4);
        expect(container.read(adProvider).showAd, false);

        await container.read(adProvider.notifier).incrementTrackCount();

        expect(container.read(adProvider).trackCount, 0);
        expect(container.read(adProvider).showAd, true);
      },
    );

    test('incrementTrackCount does nothing when premium', () async {
      final container = createContainer(isPremium: true);
      await container.read(adProvider.notifier).build();

      await container.read(adProvider.notifier).incrementTrackCount();

      expect(container.read(adProvider).trackCount, 0);
      expect(container.read(adProvider).showAd, false);
    });

    test('incrementTrackCount clears state if user becomes premium', () async {
      final container = createContainer(isPremium: false);
      await container.read(adProvider.notifier).build();

      // Increment count
      await container.read(adProvider.notifier).incrementTrackCount();
      expect(container.read(adProvider).trackCount, 1);

      // Now set premium to true in a new container or override
      final premiumContainer = ProviderContainer(
        overrides: [
          isPremiumProvider.overrideWithValue(true),
          premiumProvider.overrideWith(
            () => MockPremiumNotifierWrapper(
              const PremiumState(isInitialized: true, subscription: null),
            ),
          ),
        ],
      );
      await premiumContainer.read(adProvider.notifier).build();

      // Set count manually via SharedPreferences to simulate state before being premium
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('ad_track_count', 3);
      await premiumContainer.read(adProvider.notifier).incrementTrackCount();

      expect(premiumContainer.read(adProvider).trackCount, 0);
      expect(premiumContainer.read(adProvider).showAd, false);
      expect(prefs.getInt('ad_track_count'), 0);
    });

    test('_waitForPremiumInitialization timeouts after 3 seconds', () async {
      final container = createContainer(isInitialized: false);

      fakeAsync((async) {
        // Trigger build
        container.read(adProvider);
        async.flushMicrotasks();

        bool completed = false;
        bool? result;
        // Accessing the private method via incrementTrackCount
        container.read(adProvider.notifier).incrementTrackCount().then((_) {
          completed = true;
        });

        // Advance time to 4 seconds - should be completed by timeout (3s)
        async.elapse(const Duration(seconds: 4));

        // Use flushMicrotasks again to ensure then() is called
        async.flushMicrotasks();

        expect(completed, true);
        // Even if it timed out, it should still have proceeded to check isPremium
        // In our container isPremium is false, so it should have incremented count from 0 to 1
        expect(container.read(adProvider).trackCount, 1);
      });
    });

    test('dismissAd sets showAd to false', () async {
      final container = createContainer();
      await container.read(adProvider.notifier).build();

      // Reach threshold
      for (int i = 0; i < 5; i++) {
        await container.read(adProvider.notifier).incrementTrackCount();
      }
      expect(container.read(adProvider).showAd, true);

      container.read(adProvider.notifier).dismissAd();

      expect(container.read(adProvider).showAd, false);
    });
  });
}

class MockPremiumNotifierWrapper extends PremiumNotifier {
  final PremiumState _initialState;
  MockPremiumNotifierWrapper(this._initialState);

  @override
  PremiumState build() => _initialState;
}
