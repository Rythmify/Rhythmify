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

  testWidgets('M5 - PLAYER - All scenarios', (tester) async {
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
      await playerPage.playFromHotForYou();
      expect(playerPage.isMiniPlayerVisible(), true);
      await playerPage.openFullPlayer();
      await tester.pump(const Duration(seconds: 3));
    });

    await tryTest('Check visibility', () async {
      expect(playerPage.isTrackInfoVisible(), true);
      expect(playerPage.isCollapseVisible(), true);
      expect(playerPage.isFollowVisible(), true);
      expect(playerPage.isActionBarVisible(), true);
    });

    await tryTest('Check Follow & collapse & like button tappble', () async {
      await playerPage.tapFollowButton();
      await tester.pump(const Duration(seconds: 3));
      await playerPage.tapCollapseButton();
      await tester.pump(const Duration(seconds: 3));
      await playerPage.openFullPlayer();
      await tester.pump(const Duration(seconds: 3));
      await playerPage.tapLikeButton();
      await tester.pump(const Duration(seconds: 3));
    });

    await tryTest('Play & Pause track without crashing', () async {    
      await playerPage.tapPlayPause(); // pause
      await tester.pump(const Duration(seconds: 1));
      await playerPage.tapPlayPause(); // resume
      await tester.pump(const Duration(seconds: 1));
    });

    // ── TC-PLAYER-006 | Drag WaveForm Smoothly ───
    // await tryTest('Drag WaveForm Smoothly', () async {
    //   await tester.pump(const Duration(seconds: 2));
    //   // The waveform timestamp is drawn on canvas (not a Text widget),
    //   // so we verify the drag completes without throwing.
    //   await playerPage.dragWaveformSmoothly(pixels: 120);
    //   await tester.pump(const Duration(seconds: 1));
    // });

    FlutterError.onError = originalOnError;
    if (failures.isNotEmpty) {
      final summary = failures.join('\n');
      debugPrint('\n══ TEST SUMMARY ══\n$summary');
      fail('${failures.length} test(s) failed:\n$summary');
    }
  });
}
