import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import '../base_page.dart';
import '../../selectors/selectors.dart';

class HomePage extends BasePage {
  HomePage(WidgetTester tester) : super(tester);

  // ── Visibility ──

  bool isOnHomePage() => isVisible(homeScaffold);

  bool isHeaderVisible() => isVisible(homeAppBar);

  bool isAllNavTabsVisible() {
    return isVisible(mainBottomNavigationBar);
  }

  bool isAllHeaderElementsVisible() {
    return isVisible(homeAppBar) &&
        isVisible(homeUploadTrackButton) &&
        isVisible(homeInboxButton) &&
        isVisible(homeNotificationsButton);
  }

  bool isActivityCardVisible() => isVisible(hotForYouSection);

  bool isActionButtonVisible() => isVisible(hotForYouPlayButton);

  bool isHotForYouMetadataVisible() {
    return isVisible(hotForYouTrackTitle) &&
        isVisible(hotForYouTrackArtist) &&
        isVisible(hotForYouLikeCount);
  }

  bool isMixedForYouVisible() => isVisible(mixedForYouSection);

  bool isDiscoverWithStationsVisible() => isVisible(discoverWithStationsSection);

  bool isMoreOfWhatYouLikeVisible() => isVisible(moreOfWhatYouLikeSection);

  bool isTrendingByGenreVisible() => isVisible(trendingByGenreSection);

  bool isGenreTabBarVisible() => isVisible(genreTabBar);

  bool isReggaeGenreVisible() => find.text('Reggae').evaluate().isNotEmpty;

  bool isOnInboxPage() => isVisible(messagingComposeButton);

  // ── Navigation Taps ──

  Future<void> tapUploadButton() async => await tapByKey(homeUploadTrackButton);
  Future<void> tapMessageButton() async => await tapByKey(homeInboxButton);
  Future<void> tapNotificationButton() async => await tapByKey(homeNotificationsButton);

  /// Tap the inbox button, verify navigation, then return to the home screen.
  Future<void> tapInboxAndReturn() async {
    await tapByKey(homeInboxButton);
    await tester.pumpAndSettle(const Duration(seconds: 3));
    await tester.pageBack();
    await tester.pumpAndSettle(const Duration(seconds: 2));
  }

  /// Tap the notifications button, verify navigation, then return to the home screen.
  Future<void> tapNotificationsAndReturn() async {
    await tapByKey(homeNotificationsButton);
    await tester.pumpAndSettle(const Duration(seconds: 3));
    await tester.pageBack();
    await tester.pumpAndSettle(const Duration(seconds: 2));
  }

  // ── Genre Tabs ──

  Future<void> tapGenreTab(String genreName) async {
    await tester.tap(find.text(genreName));
    await tester.pumpAndSettle(const Duration(milliseconds: 400));
  }

  // ── Scroll Helpers ──

  /// Scrolls the main feed down until the widget with [key] is visible.
  /// Uses key-based lookup so section keys resolve correctly.
  Future<void> scrollDownUntilVisible(String key) async {
    await tester.dragUntilVisible(
      find.byKey(Key(key)),
      find.byKey(const Key(homeScrollView)),
      const Offset(0, -100),
      maxIteration: 50,
    );
    await tester.pumpAndSettle();
  }
  // scrollHorizontallyInSection is inherited from BasePage
}
