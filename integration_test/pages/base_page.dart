// base page here

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';

class BasePage {
  final WidgetTester tester;

  BasePage(this.tester);

  Future<void> tapByKey(String key) async {
    await tester.ensureVisible(find.byKey(Key(key)));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(Key(key)));
    await tester.pumpAndSettle();
  }

  /// Same as [tapByKey] but uses fixed [pump] calls instead of [pumpAndSettle].
  /// Use this whenever audio is playing — the continuous frame updates from the
  /// player prevent [pumpAndSettle] from ever settling.
  Future<void> tapByKeyNow(String key) async {
    await tester.ensureVisible(find.byKey(Key(key)));
    await tester.pump(const Duration(milliseconds: 300));
    await tester.tap(find.byKey(Key(key)));
    await tester.pump(const Duration(milliseconds: 300));
  }

  Future<void> enterTextByKey(String key, String text) async {
    await tester.enterText(find.byKey(Key(key)), text);
    await tester.pumpAndSettle();
  }

  Future<void> scrollUntilVisible({
      required String itemText,
      required String scrollableKey,
    }) async {
    await tester.dragUntilVisible(
      find.text(itemText),
      find.byKey(Key(scrollableKey)),
      const Offset(0, -100),
      maxIteration: 50,
    );
    await tester.pumpAndSettle();
  }

  /// Drags the widget identified by [sectionKey] horizontally (left by 300px).
  Future<void> scrollHorizontallyInSection(String sectionKey) async {
    await tester.drag(find.byKey(Key(sectionKey)), const Offset(-300, 0));
    await tester.pumpAndSettle();
  }

  bool isVisible(String key) {
    return find.byKey(Key(key)).evaluate().isNotEmpty;
  }

  Future<void> waitForSettle() async {
    await tester.pumpAndSettle();
  }
}