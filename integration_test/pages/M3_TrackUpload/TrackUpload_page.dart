import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rythmify/features/track_upload/presentation/providers/upload_track_provider.dart';
import '../base_page.dart';
import '../../selectors/selectors.dart';

class TrackUploadPage extends BasePage {
  TrackUploadPage(super.tester);

  // ── Navigation ─────────────────────────────────────────────────────────────

  /// Taps the upload icon button in the Home AppBar.
  Future<void> goToUploadScreenFromHome() async {
    await tapByKey(homeUploadTrackButton);
    await tester.pumpAndSettle(const Duration(seconds: 2));
  }

  // ── Audio Selection Simulation ─────────────────────────────────────────────

  /// Bypasses the native OS file picker by seeding the Riverpod provider
  /// directly — the same calls that AudioPickerWidget._replaceAudio() makes
  /// after the picker resolves. [fileName] (without extension) becomes the
  /// pre-filled title; [durationSeconds] is used for the draft duration.
  Future<void> simulateAudioSelection({
    String fileName = 'Test Track.mp3',
    int durationSeconds = 210,
  }) async {
    final container = ProviderScope.containerOf(
      tester.element(find.byType(ProviderScope).last),
    );
    final notifier = container.read(uploadFormProvider.notifier);

    notifier.initDraft(
      artistId: 'dev_user_001',
      localAudioPath: '/data/local/tmp/$fileName',
      duration: Duration(seconds: durationSeconds),
      fileName: fileName,
    );
    notifier.startAudioUpload();

    // Simulated upload: 10 steps × 400 ms each
    await tester.pump(const Duration(milliseconds: 400));
    for (int i = 0; i < 10; i++) {
      await tester.pump(const Duration(milliseconds: 400));
    }
    await tester.pumpAndSettle(const Duration(seconds: 1));
  }

  // ── Provider Access ────────────────────────────────────────────────────────

  ProviderContainer _container() => ProviderScope.containerOf(
        tester.element(find.byType(ProviderScope).last),
      );

  // ── Upload Screen State Checks ─────────────────────────────────────────────

  /// True when the Upload screen is active ("Upload" title visible in AppBar).
  bool isOnUploadScreen() => find.text('Upload').evaluate().isNotEmpty;

  /// True when all three tab labels are visible.
  bool isAllTabsVisible() =>
      find.text('Track Info').evaluate().isNotEmpty &&
      find.text('Advanced').evaluate().isNotEmpty &&
      find.text('Permissions').evaluate().isNotEmpty;

  /// True when the draft title is non-empty (auto-filled from filename).
  bool isAutoFilledTitleNotEmpty() =>
      (_container().read(uploadFormProvider).draft?.title ?? '').isNotEmpty;

  /// True when the draft artist is non-empty (auto-filled as "Your Name").
  bool isAutoFilledArtistNotEmpty() =>
      (_container().read(uploadFormProvider).draft?.artist ?? '').isNotEmpty;

  /// True when the draft title equals [value].
  bool isTitleValue(String value) =>
      _container().read(uploadFormProvider).draft?.title == value;

  // ── Upload Screen Actions ──────────────────────────────────────────────────

  /// Switches to the named tab ('Track Info', 'Advanced', or 'Permissions').
  Future<void> switchToTab(String tabName) async {
    await tester.tap(find.text(tabName));
    await tester.pumpAndSettle(const Duration(seconds: 1));
  }

  /// Enters [title] into the Title text field (first TextField on the Track
  /// Info tab). Fires onChanged → uploadFormProvider.notifier.setTitle.
  Future<void> enterTitle(String title) async {
    final titleField = find.byType(TextField).first;
    await tester.tap(titleField);
    await tester.pump();
    await tester.enterText(titleField, title);
    await tester.pump();
  }

  /// Opens the Genre bottom sheet and selects [genre] from the list.
  Future<void> selectGenre(String genre) async {
    await tapByKey(trackUploadGenrePicker);
    await scrollUntilVisible(
      itemText: genre,
      scrollableKey: trackUploadGenreListView,
    );
    await tester.tap(find.text(genre).last);
    await tester.pumpAndSettle(const Duration(seconds: 1));
  }

  /// Adds [tag] directly via the provider (avoids TextField submit interaction).
  Future<void> addTag(String tag) async {
    _container().read(uploadFormProvider.notifier).addTag(tag);
    await tester.pump();
  }

  /// Sets [text] as the description directly via the provider.
  Future<void> setDescription(String text) async {
    _container().read(uploadFormProvider.notifier).setDescription(text);
    await tester.pump();
  }

  /// Selects the "Unlisted (Private)" privacy option.
  Future<void> tapPrivate() async {
    await tester.ensureVisible(find.text('Unlisted (Private)'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Unlisted (Private)'));
    await tester.pumpAndSettle(const Duration(seconds: 1));
  }

  /// Selects the "Public" privacy option.
  Future<void> tapPublic() async {
    await tester.ensureVisible(find.text('Public'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Public'));
    await tester.pumpAndSettle(const Duration(seconds: 1));
  }

  /// Taps the Save button to trigger the upload.
  Future<void> tapSave() async {
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle(const Duration(seconds: 2));
  }

  // ── Progress Overlay ───────────────────────────────────────────────────────

  /// True when the upload-success overlay is visible.
  bool isSuccessMessageVisible() => isVisible(trackUploadProgressSuccess);

  /// Waits up to [maxSeconds] for the upload to resolve (success or error),
  /// pumping in 1-second increments.
  Future<void> waitForUploadResult({int maxSeconds = 30}) async {
    for (int i = 0; i < maxSeconds; i++) {
      if (isSuccessMessageVisible() || isVisible(trackUploadProgressError)) return;
      await tester.pump(const Duration(seconds: 1));
    }
  }
}
