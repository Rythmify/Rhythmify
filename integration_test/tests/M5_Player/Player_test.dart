import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:rythmify/main.dart' as app;
import '../../pages/M1_Authentication/login_page.dart';
import '../../pages/M5_Player/Player_page.dart';
import '../../fixtures/test_data.dart';
import '../../selectors/selectors.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('TC-PLAYER-001 | Full player — all checks', (tester) async {
    app.main();
    await tester.pumpAndSettle(const Duration(seconds: 5));

    final loginPage = LoginPage(tester);
    final playerPage = PlayerPage(tester);

    // ── Login ──────────────────────────────────────────────────────────────────
    await tester.tap(find.byKey(const Key(onboardingLoginButton)));
    await tester.pumpAndSettle(const Duration(seconds: 3));
    await loginPage.login(validEmail, validPassword);
    await tester.pumpAndSettle(const Duration(seconds: 5));
    expect(loginPage.isOnHomePage(), true);

    // ── Play a track from the Hot For You section ──────────────────────────────
    await playerPage.playFromHotForYou();

    // ── TC-PLAYER-001 | Mini player shows title and artist ────────────────────
    expect(playerPage.isMiniPlayerVisible(), true);

    // ── Open the full player via the mini player bar ───────────────────────────
    await playerPage.openFullPlayer();

    // ── TC-PLAYER-002 | Track info (title / artist) and "Behind this track" ───
    expect(playerPage.isTrackInfoVisible(), true);

    // ── TC-PLAYER-003 | Collapse and follow buttons are visible and tappable ───
    expect(playerPage.isCollapseAndFollowVisible(), true);
    //await playerPage.tapFollowButton();

    // ── TC-PLAYER-004 | Action bar (like / comments / share / next up / 3-dots)
    expect(playerPage.isActionBarVisible(), true);

    // ── TC-PLAYER-005 | Play / pause toggles without crashing ────────────────
    await playerPage.tapPlayPause(); // pause
    await tester.pumpAndSettle(const Duration(seconds: 1));
    await playerPage.tapPlayPause(); // resume
    await tester.pumpAndSettle(const Duration(seconds: 1));

    // ── TC-PLAYER-006 | Waveform drag forward and backward without crashing ───
    await tester.pumpAndSettle(const Duration(seconds: 2));
    await playerPage.dragWaveformForward(pixels: 150);
    await playerPage.dragWaveformBackward(pixels: 100);
    expect(playerPage.isFullPlayerOpen(), true);
  });
}
