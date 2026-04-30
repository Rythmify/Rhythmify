import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:rythmify/main.dart' as app;
import '../../pages/M12_Library/library_page.dart';
import '../../pages/M1_Authentication/login_page.dart';
import '../../pages/M13_Settings/settings_page.dart';
import '../../fixtures/test_data.dart';
import '../../selectors/selectors.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('M13 - Settings - all scenarios', (tester) async {
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
    final libraryPage = LibraryPage(tester);
    final settingsPage = SettingsPage(tester);

    // ── Login ──────────────────────────────────────────────────────────────────
    await tester.tap(find.byKey(const Key(onboardingLoginButton)));
    await tester.pumpAndSettle(const Duration(seconds: 3));
    await loginPage.login(validEmail, validPassword);
    await tester.pumpAndSettle(const Duration(seconds: 5));
    expect(loginPage.isOnHomePage(), true);


    // ─── TC-SETTINGS-001 | Navigate Setting Page ─────────────────────────
    await tryTest('TC-SETTINGS-001 | Navigate to settings page', () async {
      await libraryPage.tapLibraryNavButton();
      await tester.pumpAndSettle(const Duration(seconds: 3));
      await settingsPage.tapSettingsIcon();
      await tester.pumpAndSettle(const Duration(seconds: 3));
    });

    await tryTest('TC-SETTINGS-002 | check all tab are tapple and direct to a specific page witout crashing', () async {
      await settingsPage.tapImportMyMusic();
      await tester.pumpAndSettle(const Duration(seconds: 3));
      await settingsPage.gobackFromImportMyMusic();

      // await settingsPage.tapUpload();
      // await tester.pumpAndSettle(const Duration(seconds: 3));
      // await settingsPage.gobackFromUpload();

      await settingsPage.tapSocailSettings();
      await tester.pumpAndSettle(const Duration(seconds: 3));
      await settingsPage.gobackFromSocailSettings();

      await settingsPage.tapInbox();
      await tester.pumpAndSettle(const Duration(seconds: 3));
      await settingsPage.gobackFromInbox();

      await settingsPage.tapNotifications();
      await tester.pumpAndSettle(const Duration(seconds: 3));
      await settingsPage.gobackFromNotifications();

      await settingsPage.tapAddWidgets();
      await tester.pumpAndSettle(const Duration(seconds: 3));
      await settingsPage.gobackFromAddWidgets();
    });

    await tryTest('TC-SETTINGS-003 | Clear cache successfully', () async {  
      await settingsPage.tapBasicSettings();      
      await tester.pumpAndSettle(const Duration(seconds: 3));
      await settingsPage.tapOnClearAppCache();
      await settingsPage.tapYes();
      await settingsPage.gobackFromBasicSettings();

    });

    await tryTest('TC-SETTINGS-005 | Clear cache successfully', () async {
      await settingsPage.tapBasicSettings();  
      await tester.pumpAndSettle(const Duration(seconds: 3));
      await settingsPage.tapOnClearAppCache();
      await settingsPage.tapYes();
      await settingsPage.gobackFromBasicSettings();
    });   

    await tryTest('TC-SETTINGS-005 | Sign Out successfully', () async {
      await settingsPage.tapSignOut();
      await tester.pumpAndSettle(const Duration(seconds: 3));
      await settingsPage.tapOK();
      await tester.pumpAndSettle(const Duration(seconds: 3));
      expect (settingsPage.isOnBoardingPage(), true);
    }); 

    FlutterError.onError = originalOnError;
    if (failures.isNotEmpty) {
      final summary = failures.join('\n');
      debugPrint('\n══ TEST SUMMARY ══\n$summary');
      fail('${failures.length} test(s) failed:\n$summary');
    }
  });
}