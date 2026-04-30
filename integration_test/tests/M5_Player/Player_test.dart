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
    final originalOnError = FlutterError.onError;
    FlutterError.onError = (FlutterErrorDetails details) {
      debugPrint('[Test] Suppressed: ${details.exception}');
    };
    final List<String> failures = [];
    Future<void> tryTest(String name, Future<void> Function() body) async {
      try {
        await body();
        debugPrint('[PASS] $name');
      } catch (e) {
        failures.add('❌ $name\n   → $e');
        debugPrint('[FAIL] $name: $e');
      }
    }
    await tester.pumpAndSettle(const Duration(seconds: 5));

    final loginPage = LoginPage(tester);
    final playerPage = PlayerPage(tester);

    // ── Login ──────────────────────────────────────────────────────────────────
    await tester.tap(find.byKey(const Key(onboardingLoginButton)));
    await tester.pumpAndSettle(const Duration(seconds: 3));
    await loginPage.login(validEmail, validPassword);
    await tester.pumpAndSettle(const Duration(seconds: 5));
    expect(loginPage.isOnHomePage(), true);


    await tryTest ('Play a track & open player page', () async {
      // ── Play a track from the Hot For You section ──────────────────────────────
      await playerPage.playFromHotForYou();
      // ── TC-PLAYER-001 | Mini player shows title and artist ────────────────────
      expect(playerPage.isMiniPlayerVisible(), true);
      // ── Open the full player via the mini player bar ───────────────────────────
      await playerPage.openFullPlayer();
      await tester.pumpAndSettle(const Duration(seconds: 3));
    });

    await tryTest('Check visibility', () async {
      // ── TC-PLAYER-002 | Track info (title / artist) and "Behind this track" ───
      expect(playerPage.isTrackInfoVisible(), true);
      // ── TC-PLAYER-003 | Collapse and follow buttons are visible  ───
      expect(playerPage.isCollapseAndFollowVisible(), true);
      expect(playerPage.isActionBarVisible(), true);
    });

    await tryTest('Check Follow & collapse & like button tappble', () async { 
      await playerPage.tapFollowButton();
      await playerPage.tapCollapseButton();
      await tester.pumpAndSettle(const Duration(seconds: 3));
      await playerPage.openFullPlayer();
      await playerPage.tapLikeButton();
      await tester.pumpAndSettle(const Duration(seconds: 3));
    });


    // ── TC-PLAYER-005 | Play / pause toggles without crashing ────────────────
    await tryTest('Play & Pause track without crashing', () async {    
      await playerPage.tapPlayPause(); // pause
      await tester.pump(const Duration(seconds: 1));
      await playerPage.tapPlayPause(); // resume
      await tester.pump(const Duration(seconds: 1));
    });


    // ── TC-PLAYER-006 | Drag WaveForm Smoothly ───
    await tryTest('Drag WaveForm Smoothly', () async {    
      // 1. Wait for animations to finish
      await tester.pumpAndSettle();

      // 2. Find the timestamp finder
      final timestampFinder = find.byKey(const Key(playerProgressBarDuration));

      // 3. Robust check for existence
      expect(timestampFinder, findsOneWidget, reason: "Timestamp widget missing from player");

      final String initialTime = tester.widget<Text>(timestampFinder).data ?? "";

      // 4. Perform the drag on the waveform
      await playerPage.dragWaveformSmoothly(pixels: 120);

      // 5. Verify the time changed
      final String newTime = tester.widget<Text>(timestampFinder).data ?? "";
      expect(initialTime, isNot(equals(newTime)), reason: "Track position did not update after drag");
    });

    FlutterError.onError = originalOnError;
    if (failures.isNotEmpty) {
      final summary = failures.join('\n');
      debugPrint('\n══ TEST SUMMARY ══\n$summary');
      fail('${failures.length} test(s) failed:\n$summary');
    }
  });
}
