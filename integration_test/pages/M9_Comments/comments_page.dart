import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import '../base_page.dart';
import '../../selectors/selectors.dart';

class CommentsPage extends BasePage {
  CommentsPage(super.tester);

  // ── Navigation ─────────────────────────────────────────────────────────────

  /// Opens the Comments screen from the full-player action bar.
  Future<void> openFromPlayer() async {
    await tapByKey(playerActionBarCommentIcon);
    await tester.pump(const Duration(seconds: 3));
  }

  /// Closes the Comments screen via the X button in the AppBar.
  Future<void> close() async {
    await tester.tap(find.byIcon(Icons.close).first);
    await tester.pump(const Duration(seconds: 1));
  }

  // ── Floating Comment Bar (Full Player screen) ──────────────────────────────

  /// Taps one of the three preset emoji buttons (🔥 / 👏 / 🥺) in the
  /// floating bar, waits for the send button to appear, then posts it.
  Future<void> sendEmojiFromFloatingBar(String emoji) async {
    await tester.tap(find.text(emoji));
    await tester.pump(const Duration(milliseconds: 300));
    // After appending the emoji the send icon replaces the emoji row
    await tester.tap(find.byIcon(Icons.send).first);
    await tester.pump(const Duration(seconds: 1));
  }

  /// Types [text] into the floating comment bar's text field and posts it.
  Future<void> sendCommentFromFloatingBar(String text) async {
    await tester.enterText(find.byType(TextField).first, text);
    await tester.pump(const Duration(milliseconds: 200));
    await tester.tap(find.byIcon(Icons.send).first);
    await tester.pump(const Duration(seconds: 1));
  }

  // ── Comments Screen ─────────────────────────────────────────────────────────

  /// Types [text] into the "Add a comment…" input and posts it.
  Future<void> sendComment(String text) async {
    await tester.enterText(find.byType(TextField).first, text);
    await tester.pump(const Duration(milliseconds: 200));
    await tester.tap(find.byIcon(Icons.send).first);
    await tester.pump(const Duration(seconds: 2));
  }

  /// Taps the like (heart) button on the first comment in the list.
  Future<void> likeFirstComment() async {
    await tester.tap(find.byIcon(Icons.favorite_border).first);
    await tester.pump(const Duration(seconds: 1));
  }

  /// Taps the "Reply" label on the first visible comment,
  /// types [replyText], and posts it.
  Future<void> replyToFirstComment(String replyText) async {
    await tester.tap(find.text('Reply').first);
    await tester.pump(const Duration(milliseconds: 500));
    await tester.enterText(find.byType(TextField).first, replyText);
    await tester.pump(const Duration(milliseconds: 200));
    await tester.tap(find.byIcon(Icons.send).first);
    await tester.pump(const Duration(seconds: 2));
  }

  /// Taps "Show N replies" on the first comment that exposes a reply toggle.
  Future<void> tapShowReplies() async {
    final button = find.textContaining('replies').first;
    await tester.ensureVisible(button);
    await tester.tap(button);
    await tester.pump(const Duration(seconds: 2));
  }

  /// Taps "Show less" to collapse the currently expanded replies.
  Future<void> tapShowLess() async {
    await tester.tap(find.text('Show less'));
    await tester.pump(const Duration(seconds: 1));
  }

  /// Taps the track-timestamp chip (blue text matching mm:ss) on the first
  /// comment that has one.  The player is expected to seek to that position.
  Future<void> tapFirstTrackTimestamp() async {
    final timestampFinder = find.byWidgetPredicate(
      (widget) =>
          widget is Text &&
          widget.style?.color == Colors.blueAccent &&
          RegExp(r'^\d+:\d+$').hasMatch(widget.data ?? ''),
    );
    if (timestampFinder.evaluate().isNotEmpty) {
      await tester.tap(timestampFinder.first);
      await tester.pump(const Duration(seconds: 1));
    }
  }

  /// Taps the ⋮ (more_vert) icon on the last visible comment (which is
  /// typically the innermost / most-recently-added reply when replies are
  /// expanded).
  Future<void> tapMoreOnLastVisible() async {
    final icons = find.byIcon(Icons.more_vert);
    await tester.tap(icons.last);
    await tester.pump(const Duration(seconds: 1));
  }

  /// Taps the ⋮ (more_vert) icon on the first comment in the list.
  Future<void> tapMoreOnFirstComment() async {
    await tester.tap(find.byIcon(Icons.more_vert).first);
    await tester.pump(const Duration(seconds: 1));
  }

  /// Taps an option inside the comment action bottom sheet by its label text.
  Future<void> tapBottomSheetOption(String label) async {
    await tester.tap(find.text(label));
    await tester.pump(const Duration(seconds: 2));
  }

  /// Dismisses a visible bottom sheet by tapping outside its bounds.
  Future<void> dismissBottomSheet() async {
    await tester.tapAt(const Offset(200, 50));
    await tester.pump(const Duration(seconds: 1));
  }

  /// Taps the sort icon (tune) to open the sort options bottom sheet.
  Future<void> tapSortIcon() async {
    await tester.tap(find.byIcon(Icons.tune));
    await tester.pump(const Duration(seconds: 1));
  }

  /// Selects a sort option.  [option] must be one of: "Newest", "Oldest",
  /// "Track Time".
  Future<void> selectSortOption(String option) async {
    await tester.tap(find.text(option));
    await tester.pump(const Duration(seconds: 2));
  }

  /// Scrolls the comments list down then back up.
  Future<void> scrollCommentsList() async {
    await tester.drag(
      find.byType(CustomScrollView).first,
      const Offset(0, -300),
    );
    await tester.pump(const Duration(seconds: 1));
    await tester.drag(
      find.byType(CustomScrollView).first,
      const Offset(0, 300),
    );
    await tester.pump(const Duration(seconds: 1));
  }

  // ── State Checks ───────────────────────────────────────────────────────────

  /// True when the Comments screen AppBar title is in the tree.
  bool isCommentsScreenVisible() =>
      find.textContaining('Comments').evaluate().isNotEmpty;

  /// True when a widget with exactly [text] is in the tree.
  bool isCommentVisible(String text) =>
      find.text(text).evaluate().isNotEmpty;

  /// True when at least one "Show N replies" toggle is visible.
  bool hasShowRepliesButton() =>
      find.textContaining('replies').evaluate().isNotEmpty;

  /// True when "Show less" is visible (replies are currently expanded).
  bool isShowLessVisible() =>
      find.text('Show less').evaluate().isNotEmpty;

  /// True when the filled heart icon is visible (a comment has been liked).
  bool isLikedHeartVisible() =>
      find.byIcon(Icons.favorite).evaluate().isNotEmpty;

  /// True when [label] text is currently shown in a bottom sheet row.
  bool isBottomSheetOptionVisible(String label) =>
      find.text(label).evaluate().isNotEmpty;
}
