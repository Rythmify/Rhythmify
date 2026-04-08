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

  Future<void> enterTextByKey(String key, String text) async {
    await tester.enterText(find.byKey(Key(key)), text);
    await tester.pumpAndSettle();
  }

  bool isVisible(String key) {
    return find.byKey(Key(key)).evaluate().isNotEmpty;
  }

  Future<void> waitForSettle() async {
    await tester.pumpAndSettle();
  }
}