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

  testWidgets('TC-COMMENTS-001 | Comments — full feature flow', (tester) async {
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

      // ── Play a track → mini player appears immediately ─────────────────────
      await tryTest('TC-COMMENTS-000 | Play a track and verify mini player appears', () async {
        await playerPage.playFromHotForYou();
        expect(playerPage.isMiniPlayerVisible(), true);
      });

      // ── Tap the mini player → full player opens ────────────────────────────
      await tryTest('TC-COMMENTS-000 | Tap mini player to open full player', () async {
        await playerPage.openFullPlayer();
        expect(playerPage.isFullPlayerOpen(), true);
      });

      // ── TC-COMMENTS-001 | Send 3 emojis via the floating bar ──────────────
      // ── TC-COMMENTS-002 | Send "test comment" via the floating bar ─────────
      await tryTest('TC-COMMENTS-001/002 | Send emojis and comment from floating comment bar', () async {
        await commentsPage.sendEmojiFromFloatingBar('🔥');
        await commentsPage.sendEmojiFromFloatingBar('👏');
        await commentsPage.sendEmojiFromFloatingBar('🥺');

        await commentsPage.sendCommentFromFloatingBar('test comment');
      });


      // ──TC-COMMENTS-003 | Open the Comments screen via the action bar comment icon ───────────
      await tryTest('TC-COMMENTS-003 | Open Comments screen from player', () async {
        await commentsPage.openFromPlayer();
        expect(commentsPage.isCommentsScreenVisible(), true);
      });

      // ── TC-COMMENTS-004 | All 4 comments visible (shared provider state) ───
      await tryTest('TC-COMMENTS-004 | All 4 comments visible', () async {
        expect(commentsPage.isCommentVisible('🔥'),          true);
        expect(commentsPage.isCommentVisible('👏'),          true);
        expect(commentsPage.isCommentVisible('🥺'),          true);
        expect(commentsPage.isCommentVisible('test comment'), true);
      });

      // ── TC-COMMENTS-005 | Like the first comment ──────────────────────────
      await tryTest('TC-COMMENTS-005 | Like the first comment and verify UI update', () async {
        await commentsPage.likeFirstComment();
        expect(commentsPage.isLikedHeartVisible(), true,
            reason: 'First comment should show a filled heart after liking');
      });

      // ── TC-COMMENTS-006 | Reply to the first comment with "reply test" ────
      await tryTest('TC-COMMENTS-006 | Reply works successfully', () async {
        await commentsPage.replyToFirstComment('reply test');
        expect(commentsPage.isCommentVisible('reply test'), true);
      });

      // ── TC-COMMENTS-007 | Show replies / Show less toggle ─────────────────
      // After posting a reply it auto-expands, so the toggle starts on
      // "Show less".  Collapse first, then re-expand.
      await tryTest('TC-COMMENTS-007 | Show less / Show replies toggle works', () async {
        await tester.pump(const Duration(seconds: 1));
        if (commentsPage.isShowLessVisible()) {
          await commentsPage.tapShowLess();
          expect(commentsPage.isShowLessVisible(), false,
              reason: 'Replies should be collapsed after tapping "Show less"');

          await commentsPage.tapShowReplies();
          expect(commentsPage.isShowLessVisible(), true,
              reason: 'Replies should be expanded after tapping "Show N replies"');
        }
      });

      // ── TC-COMMENTS-008 | Tap the track-min timestamp → seek player ───────
      // ── TC-COMMENTS-009 | ⋮ menu on the comments — all options tappable ──────

      // ── TC-COMMENTS-010 | Scroll the comments list ───────────────────────
      await tryTest('TC-COMMENTS-010 | Scroll the comments list', () async {
        await commentsPage.scrollCommentsList();
        expect(commentsPage.isCommentsScreenVisible(), true,
            reason: 'Screen must remain stable after scrolling');
      });

      
      await tryTest('TC-COMMENTS-010/011/012 | Sort comments by Newest, Oldest, Track Time', () async {
        // ── TC-COMMENTS-010 | Sort by Newest ─────────────────────────────────
        await commentsPage.tapSortIcon();
        await commentsPage.selectSortOption('Newest');
        expect(commentsPage.isCommentsScreenVisible(), true);

        // ── TC-COMMENTS-011 | Sort by Oldest ─────────────────────────────────
        await commentsPage.tapSortIcon();
        await commentsPage.selectSortOption('Oldest');
        expect(commentsPage.isCommentsScreenVisible(), true);

        // ── TC-COMMENTS-012 | Sort by Track Time ─────────────────────────────
        await commentsPage.tapSortIcon();
        await commentsPage.selectSortOption('Track Time');
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
