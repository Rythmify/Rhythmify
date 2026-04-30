import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import '../base_page.dart';
import '../../selectors/selectors.dart';

class SettingsPage extends BasePage {
  SettingsPage(super.tester);

  // ── Visibility ────────────────────────────────────────────────────────────

  bool isOnBoardingPage() => isVisible(onboardingLoginButton);

  // ── Main Settings screen ──────────────────────────────────────────────────

  /// The settings icon lives on the Library tab — tap it to open Settings.
  Future<void> tapSettingsIcon() async {
    await tapByKey(librarySettingsButton);
  }

  Future<void> tapImportMyMusic() async {
    await tapByKey(settingsOptionImportMyMusic);
  }

  Future<void> tapAccount() async {
    await tapByKey(settingsOptionAccount);
  }

  Future<void> tapUpload() async {
    await tapByKey(settingsOptionUpload);
  }

  Future<void> tapBasicSettings() async {
    await tapByKey(settingsOptionBasicSettings);
  }

  Future<void> tapSocailSettings() async {
    await tapByKey(settingsOptionSocialSettings);
  }

  Future<void> tapInbox() async {
    await tapByKey(settingsOptionInbox);
  }

  Future<void> tapNotifications() async {
    await tapByKey(settingsOptionNotifications);
  }

  Future<void> tapAddWidgets() async {
    await tapByKey(settingsOptionAddWidgets);
  }

  // ── Back navigation ───────────────────────────────────────────────────────
  // Using tester.pageBack() — triggers the Navigator back action,
  // no dedicated key needed for sub-screen back buttons.

  Future<void> gobackFromImportMyMusic() async {
    await tester.pageBack();
    await tester.pump(const Duration(milliseconds: 500));
  }

  Future<void> gobackFromUpload() async {
    await tester.pageBack();
    await tester.pump(const Duration(milliseconds: 500));
  }

  Future<void> gobackFromBasicSettings() async {
    await tester.pageBack();
    await tester.pump(const Duration(milliseconds: 500));
  }

  Future<void> gobackFromSocailSettings() async {
    await tester.pageBack();
    await tester.pump(const Duration(milliseconds: 500));
  }

  Future<void> gobackFromInbox() async {
    await tester.pageBack();
    await tester.pump(const Duration(milliseconds: 500));
  }

  Future<void> gobackFromNotifications() async {
    await tester.pageBack();
    await tester.pump(const Duration(milliseconds: 500));
  }

  Future<void> gobackFromAddWidgets() async {
    await tester.pageBack();
    await tester.pump(const Duration(milliseconds: 500));
  }

  // ── Basic settings screen ─────────────────────────────────────────────────

  Future<void> tapOnClearAppCache() async {
    await tapByKey(settingsClearCacheTile);
  }

  // ── Confirmation dialogs ──────────────────────────────────────────────────
  // Clear-cache and sign-out dialogs use standard AlertDialog text buttons —
  // no dedicated keys exist in the codebase.

  Future<void> tapYes() async {
    await tester.tap(find.text('Yes'));
    await tester.pump(const Duration(milliseconds: 500));
  }

  Future<void> tapOK() async {
    await tester.tap(find.text('OK'));
    await tester.pump(const Duration(milliseconds: 500));
  }

  // ── Account screen ────────────────────────────────────────────────────────

  Future<void> tapSignOut() async {
    await tapByKey(settingsSignOutButton);
  }
}
