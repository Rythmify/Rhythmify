import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import '../base_page.dart';
import '../../selectors/selectors.dart';

class PlayerPage extends BasePage {
  PlayerPage(super.tester);

  // ── Navigation ──────────────────────────────────────────────────────────────

  /// Taps the play button on the first Hot For You track card.
  Future<void> playFromHotForYou() async {
    await tapByKey(hotForYouPlayButton);
    await tester.pump(const Duration(seconds: 3));
  }

  /// Taps the mini player bar to open the full player.
  Future<void> openFullPlayer() async {
    await tester.tap(find.byKey(const Key(playerMiniPlayerGesture)));
    await tester.pump(const Duration(seconds: 2));
  }

  /// Taps the collapse (arrow-down) button to close the full player.
  Future<void> collapsePlayer() async {
    await tapByKey(playerFullPageCollapse);
    await tester.pumpAndSettle(const Duration(seconds: 2));
  }

  /// Taps the follow/unfollow icon button inside the full player.
  Future<void> tapFollowButton() async {
    await tapByKey(playerFullPageAddPerson);
    await tester.pumpAndSettle(const Duration(seconds: 2));
  }

  /// Taps the full-screen GestureDetector to toggle play / pause.
  Future<void> tapPlayPause() async {
    await tapByKey(playerFullPageTogglePlay);
    await tester.pumpAndSettle(const Duration(seconds: 1));
  }

  /// Taps the comment icon in the action bar.
  Future<void> tapCommentIcon() async {
    await tapByKey(playerActionBarCommentIcon);
    await tester.pumpAndSettle(const Duration(seconds: 2));
  }

  /// Drags the waveform to the left (seeks forward in time) by [pixels].
  Future<void> dragWaveformForward({double pixels = 150}) async {
    await tester.drag(
      find.byType(CustomPaint).first,
      Offset(-pixels, 0),
    );
    await tester.pumpAndSettle(const Duration(milliseconds: 500));
  }

  /// Drags the waveform to the right (seeks backward in time) by [pixels].
  Future<void> dragWaveformBackward({double pixels = 150}) async {
    await tester.drag(
      find.byType(CustomPaint).first,
      Offset(pixels, 0),
    );
    await tester.pumpAndSettle(const Duration(milliseconds: 500));
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
      isVisible(playerFullPageAddPerson);

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
