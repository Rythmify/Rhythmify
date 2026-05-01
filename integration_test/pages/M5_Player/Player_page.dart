import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import '../base_page.dart';
import '../../selectors/selectors.dart';

class PlayerPage extends BasePage {
  PlayerPage(super.tester);

  // ── Navigation ──────────────────────────────────────────────────────────────

  /// Taps the play button on the first Hot For You track card.
  Future<void> playFromHotForYou() async {
    await tester.ensureVisible(find.byKey(const Key(hotForYouPlayButton)));
    await tester.pump(const Duration(milliseconds: 300));
    await tester.tap(find.byKey(const Key(hotForYouPlayButton)));
    await tester.pump(const Duration(seconds: 2)); // allow mini player to render
  }

  /// Taps the mini player bar to open the full player.
  Future<void> openFullPlayer() async {
    await tester.tap(find.byKey(const Key(playerMiniPlayerGesture)));
    await tester.pump(const Duration(seconds: 3));
  }

  /// Taps the collapse (arrow-down) button to close the full player.
  Future<void> tapCollapseButton() async {
    await tapByKeyNow(playerFullPageCollapse);
    await tester.pump(const Duration(seconds: 2));
  }

  /// Taps the follow/unfollow icon button inside the full player.
  Future<void> tapFollowButton() async {
      await tester.tap(find.byIcon(Icons.person_add));
      await tester.pump(const Duration(seconds: 2));
  }

  /// Taps the full-screen GestureDetector to toggle play / pause.
  Future<void> tapPlayPause() async {
    await tapByKeyNow(playerFullPageTogglePlay);
    await tester.pump(const Duration(seconds: 1));
  }

  /// Taps the comment icon in the action bar.
  Future<void> tapLikeButton() async {
    await tapByKeyNow(playerActionBarFavorite);
    await tester.pump(const Duration(seconds: 2));
  }

  Future<void> dragWaveformSmoothly({required double pixels}) async {
    final waveformFinder = find.byType(CustomPaint).first;
    
    // Ensure the waveform is actually there before touching it
    await tester.ensureVisible(waveformFinder);
    
    final Offset center = tester.getCenter(waveformFinder);

    // We touch slightly above the center to ensure we hit the bars 
    // if the 'base' of the custom paint isn't interactive.
    final Offset touchPoint = center + const Offset(0, -10); 

    final TestGesture gesture = await tester.startGesture(touchPoint);
    
    // Small increments allow the internal 'onHorizontalDragUpdate' to fire
    final int steps = 10;
    for (int i = 0; i < steps; i++) {
      await gesture.moveBy(Offset(-pixels / steps, 0));
      await tester.pump(const Duration(milliseconds: 30));
    }
    
    await gesture.up();
    await tester.pump(const Duration(seconds: 1));
  }

  // ── State Checks ─────────────────────────────────────────────────────────────

  /// True when the mini player is rendered and shows a title + artist.
  bool isMiniPlayerVisible() =>
      isVisible(playerMiniPlayerGesture) &&
      isVisible(playerMiniPlayerTitle) &&
      isVisible(playerMiniPlayerArtist);

  /// True when the track-info box (title/artist) and "Behind this track"
  /// button are both rendered in the full player.
  bool isTrackInfoVisible() =>
      isVisible(playerTrackInfoBoxDetails) &&
      isVisible(behindTheTrackBehindTrackButton);

  /// True when the collapse and follow buttons are rendered.
bool isCollapseAndFollowVisible() =>
    isVisible(playerFullPageCollapse) &&
    find.byIcon(Icons.person_add).evaluate().isNotEmpty;

  /// True when all five action-bar items are rendered.
  bool isActionBarVisible() =>
      isVisible(playerActionBarFavorite) &&
      isVisible(playerActionBarCommentIcon) &&
      isVisible(playerActionBarShareIcon) &&
      isVisible(playerActionBarPlaylistIcon) &&
      isVisible(playerActionBarMoreIcon);

  /// True when the full player page is rendered (collapse button present).
  bool isFullPlayerOpen() => isVisible(playerFullPageCollapse);
}
