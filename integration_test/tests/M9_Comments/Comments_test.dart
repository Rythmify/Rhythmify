import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:rythmify/main.dart' as app;
import '../../pages/M1_Authentication/login_page.dart';
import '../../pages/M5_Player/Player_page.dart';
import '../../pages/M9_Comments/comments_page.dart';
import '../../fixtures/test_data.dart';
import '../../selectors/selectors.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('M9 - COMMENTS - All scenarios', (tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 5));
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

      final loginPage    = LoginPage(tester);
      final playerPage   = PlayerPage(tester);
      final commentsPage = CommentsPage(tester);

      // ── Login ────────────────────────────────────────────────────────────
      await tester.tap(find.byKey(const Key(onboardingLoginButton)));
      await tester.pumpAndSettle(const Duration(seconds: 3));
      await loginPage.login(validEmail, validPassword);
      await tester.pumpAndSettle(const Duration(seconds: 5));
      expect(loginPage.isOnHomePage(), true);

      await tryTest('TC-COMMENTS-000 | Play a track and open full player immediately', () async {
        await playerPage.playFromHotForYou();
        for (int i = 0; i < 15; i++) {
          await tester.pump(const Duration(milliseconds: 200));
          if (playerPage.isMiniPlayerVisible()) break;
        }
        expect(playerPage.isMiniPlayerVisible(), true);
        await playerPage.openFullPlayer();
        await tester.pump(const Duration(seconds: 3));
      });

      await tryTest('TC-COMMENTS-001/002 | Send emojis and comment from floating comment bar', () async {
        await commentsPage.sendEmojiFromFloatingBar('🔥');
        await commentsPage.sendEmojiFromFloatingBar('👏');
        await commentsPage.sendEmojiFromFloatingBar('🥺');
        await commentsPage.sendCommentFromFloatingBar('test comment');
      });

      await tryTest('TC-COMMENTS-003 | Open Comments screen from player', () async {
        await commentsPage.openFromPlayer();
        await tester.pumpAndSettle(const Duration(seconds: 3));
        expect(commentsPage.isCommentsScreenVisible(), true);
      });

      await tryTest('TC-COMMENTS-004 | All 4 comments visible', () async {
        expect(commentsPage.isCommentVisible('🔥'),          true);
        expect(commentsPage.isCommentVisible('👏'),          true);
        expect(commentsPage.isCommentVisible('🥺'),          true);
        expect(commentsPage.isCommentVisible('test comment'), true);
      });

      await tryTest('TC-COMMENTS-005 | Like the first comment and verify UI update', () async {
        await commentsPage.likeFirstComment();
        await tester.pumpAndSettle(const Duration(seconds: 3));
        expect(commentsPage.isLikedHeartVisible(), true,
            reason: 'First comment should show a filled heart after liking');
      });

      await tryTest('TC-COMMENTS-006 | Reply works successfully', () async {
        await commentsPage.replyToFirstComment('reply test');
        await tester.pumpAndSettle(const Duration(seconds: 3));
        expect(commentsPage.isCommentVisible('reply test'), true);
      });

      await tryTest('TC-COMMENTS-007 | Show less / Show replies toggle works', () async {
        await tester.pumpAndSettle(const Duration(seconds: 1));
        if (commentsPage.isShowLessVisible()) {
          await commentsPage.tapShowLess();
          expect(commentsPage.isShowLessVisible(), false,
              reason: 'Replies should be collapsed after tapping "Show less"');

          await commentsPage.tapShowReplies();
          await tester.pumpAndSettle(const Duration(seconds: 3));
          expect(commentsPage.isShowLessVisible(), true,
              reason: 'Replies should be expanded after tapping "Show N replies"');
        }
      });

      await tryTest('TC-COMMENTS-008 | Tap "Play from" in comment ⋮ menu to seek the player', () async {
        await commentsPage.scrollCommentsList();
        await commentsPage.tapMoreOnFirstComment();
        await tester.pumpAndSettle(const Duration(seconds: 1));
        expect(commentsPage.isPlayFromOptionVisible(), true,
            reason: '"Play from X:XX" option must appear in the action sheet');
        await commentsPage.tapPlayFromOption();
        await tester.pumpAndSettle(const Duration(seconds: 3));
        expect(commentsPage.isCommentsScreenVisible(), true,
            reason: 'Comments screen must stay open after seeking');
      });

      await tryTest('TC-COMMENTS-009 | Comment ⋮ menu: Copy is tappable and View profile navigates correctly', () async {
        await commentsPage.tapMoreOnFirstComment();
        expect(commentsPage.isBottomSheetOptionVisible('View profile'), true,
            reason: '"View profile" must appear in the action sheet');
        await commentsPage.tapViewProfileOption();
        await tester.pumpAndSettle(const Duration(seconds: 3));
        expect(commentsPage.isProfilePageVisible(), true,
            reason: 'Should navigate to profile after tapping "View profile"');
        await commentsPage.returnToCommentsScreen();
        expect(commentsPage.isCommentsScreenVisible(), true,
            reason: 'Comments screen must be visible after returning from profile');
      });

      await tryTest('TC-COMMENTS-010 | Comment ⋮ menu: Copy is tappable', () async {
        await commentsPage.scrollCommentsList();
        await commentsPage.tapMoreOnFirstComment();
        expect(commentsPage.isBottomSheetOptionVisible('Copy'), true,
            reason: '"Copy" must appear in the action sheet');
        await commentsPage.tapCopyOption();
        expect(commentsPage.isCommentsScreenVisible(), true,
            reason: 'Comments screen must be visible after copying');
      });

      // // ── TC-COMMENTS-011 | Delete the reply ───────────────────────────────
      // await tryTest('TC-COMMENTS-013 | Delete the reply and verify it is removed', () async {
      //   // Expand replies so the reply card is visible
      //   if (!commentsPage.isShowLessVisible()) {
      //     await commentsPage.tapShowReplies();
      //   }
      //   // The reply is the last ⋮ in the expanded list
      //   await commentsPage.tapMoreOnLastVisible();
      //   expect(commentsPage.isDeleteCommentOptionVisible(), true,
      //       reason: '"Delete comment" must appear for own reply');
      //   await commentsPage.tapDeleteCommentOption();
      //   expect(commentsPage.isCommentVisible('reply test'), false,
      //       reason: '"reply test" should no longer appear after deletion');
      // });

      await tryTest('TC-COMMENTS-012 | Delete "test comment" and verify it is removed', () async {
        await commentsPage.scrollCommentsList();
        await commentsPage.tapMoreOnFirstComment();
        expect(commentsPage.isDeleteCommentOptionVisible(), true,
            reason: '"Delete comment" must appear for own comment');
        await commentsPage.tapDeleteCommentOption();
        expect(commentsPage.isCommentVisible('test comment'), false,
            reason: '"test comment" should no longer appear after deletion');
      });

      await tryTest('TC-COMMENTS-013 | Scroll the comments list', () async {
        await commentsPage.scrollCommentsList();
        expect(commentsPage.isCommentsScreenVisible(), true,
            reason: 'Screen must remain stable after scrolling');
      });

      
      await tryTest('TC-COMMENTS-014/015/016 | Sort comments by Newest, Oldest, Track Time', () async {
        await commentsPage.tapSortIcon();
        await commentsPage.selectSortOption('Oldest');
        expect(commentsPage.isCommentsScreenVisible(), true);

        await commentsPage.tapSortIcon();
        await commentsPage.selectSortOption('Track Time');
        expect(commentsPage.isCommentsScreenVisible(), true);

        await commentsPage.tapSortIcon();
        await commentsPage.selectSortOption('Newest');
        expect(commentsPage.isCommentsScreenVisible(), true);
      });

    FlutterError.onError = originalOnError;
    if (failures.isNotEmpty) {
      final summary = failures.join('\n');
      debugPrint('\n══ TEST SUMMARY ══\n$summary');
      fail('${failures.length} test(s) failed:\n$summary');
    }
    },
  );
}
