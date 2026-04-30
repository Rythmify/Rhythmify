import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import '../base_page.dart';
import '../../selectors/selectors.dart';

class PremiumPage extends BasePage {
  PremiumPage(super.tester);

  Future<void> _tapByText(String text) async {
    await tester.tap(find.text(text));
    await tester.pumpAndSettle();
  }

  // ── Navigation ─────────────────────────────────────────────────────────────
  Future<void> tapUpgradeNavButton() async => await tapByKey(upgradeNavButton);

  // ── Landing screen ─────────────────────────────────────────────────────────
  bool isButtonsVisible() =>
      find.text('Continue').evaluate().isNotEmpty &&
      find.text('See all plans').evaluate().isNotEmpty;

  Future<void> tapContinueButton()     async => await _tapByText('Continue');
  Future<void> tapSeeAllPlansButton()  async => await _tapByText('See all plans');

  // ── Checkout screen ────────────────────────────────────────────────────────
  Future<void> tapConfirmPaymentButton() async => await _tapByText('Confirm Payment');

  // ── Success sheet ──────────────────────────────────────────────────────────
  Future<void> tapStartExploring() async => await _tapByText('Start exploring');

  // ── All Plans screen (PageView — no key in app, use byType) ───────────────
  @override
  Future<void> scrollHorizontallyInSection(String sectionKey) async {
    await tester.drag(find.byType(PageView).first, const Offset(-300, 0));
    await tester.pumpAndSettle();
  }

  // ── Scrolling (no key on SingleChildScrollView — use byType) ──────────────
  @override
  Future<void> scrollUntilVisible({
    required String itemText,
    required String scrollableKey,
  }) async {
    await tester.dragUntilVisible(
      find.text(itemText),
      find.byType(SingleChildScrollView).first,
      const Offset(0, -50),
    );
    await tester.pumpAndSettle();
  }

  // ── Manage subscription (upgrade_screen → /cancellation) ──────────────────
  Future<void> tapMangeSubscribtionButton() async =>
      await _tapByText('Manage subscription');

  // ── Cancellation screen ────────────────────────────────────────────────────
  // Opens the cancel dialog then taps "Keep Premium" to dismiss it.
  Future<void> tapKeepsubscribtionButton() async {
    await _tapByText('Cancel subscription');
    await tester.pumpAndSettle(const Duration(seconds: 1));
    await _tapByText('Keep Premium');
  }

  // Opens the cancel dialog then confirms cancellation.
  Future<void> tapCancelSubscribtionButton() async {
    await _tapByText('Cancel subscription');
    await tester.pumpAndSettle(const Duration(seconds: 1));
    await _tapByText('Cancel anyway');
  }
}
