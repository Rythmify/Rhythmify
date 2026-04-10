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

  testWidgets(
    'TC-COMMENTS-001 | Comments — full feature flow',
    (tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 5));

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
      await playerPage.playFromHotForYou();
      expect(playerPage.isMiniPlayerVisible(), true);

      // ── Tap the mini player → full player opens ────────────────────────────
      await playerPage.openFullPlayer();
      expect(playerPage.isFullPlayerOpen(), true);

        // ── TC-COMMENTS-001 | Send 3 emojis via the floating bar ──────────────
        await commentsPage.sendEmojiFromFloatingBar('🔥');
        await commentsPage.sendEmojiFromFloatingBar('👏');
        await commentsPage.sendEmojiFromFloatingBar('🥺');

        // ── TC-COMMENTS-002 | Send "test comment" via the floating bar ─────────
        await commentsPage.sendCommentFromFloatingBar('test comment');

        // ── Open the Comments screen via the action bar comment icon ───────────
        await commentsPage.openFromPlayer();
        expect(commentsPage.isCommentsScreenVisible(), true);

      // ── TC-COMMENTS-003 | All 4 comments visible (shared provider state) ───
        expect(commentsPage.isCommentVisible('🔥'),          true);
        expect(commentsPage.isCommentVisible('👏'),          true);
        expect(commentsPage.isCommentVisible('🥺'),          true);
        expect(commentsPage.isCommentVisible('test comment'), true);

      // ── TC-COMMENTS-004 | Like the first comment ──────────────────────────
      await commentsPage.likeFirstComment();
      expect(commentsPage.isLikedHeartVisible(), true,
          reason: 'First comment should show a filled heart after liking');

      // ── TC-COMMENTS-005 | Reply to the first comment with "reply test" ────
      await commentsPage.replyToFirstComment('reply test');
      expect(commentsPage.isCommentVisible('reply test'), true);

      // ── TC-COMMENTS-006 | Show replies / Show less toggle ─────────────────
      // After posting a reply it auto-expands, so the toggle starts on
      // "Show less".  Collapse first, then re-expand.
      await tester.pump(const Duration(seconds: 1));
      if (commentsPage.isShowLessVisible()) {
        await commentsPage.tapShowLess();
        expect(commentsPage.isShowLessVisible(), false,
            reason: 'Replies should be collapsed after tapping "Show less"');

        await commentsPage.tapShowReplies();
        expect(commentsPage.isShowLessVisible(), true,
            reason: 'Replies should be expanded after tapping "Show N replies"');
      }

      // ── TC-COMMENTS-007 | Tap the track-min timestamp → seek player ───────
      // The timestamp chip (blue mm:ss text) on the first comment links the
      // player to the second the comment was posted at.  Tapping it calls
      // playerStateProvider.seek() and should NOT crash or dismiss the screen.
      await commentsPage.tapFirstTrackTimestamp();
      expect(commentsPage.isCommentsScreenVisible(), true,
          reason: 'Screen must still be visible after tapping a timestamp');

      // ── TC-COMMENTS-008 | ⋮ menu on the reply — all options tappable ──────
      // Re-expand replies so the reply card is in the tree.
      if (commentsPage.hasShowRepliesButton()) {
        await commentsPage.tapShowReplies();
        await tester.pump(const Duration(seconds: 1));
      }

      await commentsPage.tapMoreOnLastVisible();

      // Verify at least the shared options are present without crashing.
      expect(commentsPage.isBottomSheetOptionVisible('Copy'),            true);
      expect(commentsPage.isBottomSheetOptionVisible('Go to profile'),   true);

      // "Play from" row always appears in the sheet.
      expect(
        find.textContaining('Play from').evaluate().isNotEmpty,
        true,
        reason: '"Play from X:XX" option must appear in the 3-dots sheet',
      );

      if (commentsPage.isBottomSheetOptionVisible('Delete comment')) {
        // The reply was posted by the current mocked user (isMe == true).
        // Tapping Delete should remove the reply from the list.
        await commentsPage.tapBottomSheetOption('Delete comment');
        await tester.pump(const Duration(seconds: 2));
        expect(commentsPage.isCommentVisible('reply test'), false,
            reason: 'Reply should be deleted after tapping "Delete comment"');
      }
      // } else {
      //   // isMe == false branch: verify report / block options are tappable.
      //   expect(commentsPage.isBottomSheetOptionVisible('Report user'), true);
      //   expect(commentsPage.isBottomSheetOptionVisible('Block'),        true);
      //   await commentsPage.dismissBottomSheet();
      // }

      // ── TC-COMMENTS-009 | Scroll the comments list ───────────────────────
      await commentsPage.scrollCommentsList();
      expect(commentsPage.isCommentsScreenVisible(), true,
          reason: 'Screen must remain stable after scrolling');

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
    },
  );
}
