import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:rythmify/main.dart' as app;
import '../../pages/M1_Authentication/login_page.dart';
import '../../pages/M3_TrackUpload/TrackUpload_page.dart';
import '../../fixtures/test_data.dart';
import '../../selectors/selectors.dart';

const _testFileName = 'Test Track.mp3';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('TC-UPLOAD-001 | Upload track from device successfully',
      (tester) async {
    app.main();
    await tester.pumpAndSettle(const Duration(seconds: 5));

    final loginPage  = LoginPage(tester);
    final uploadPage = TrackUploadPage(tester);

    // ── Login ──────────────────────────────────────────────────────────────
    await tester.tap(find.byKey(const Key(onboardingLoginButton)));
    await tester.pumpAndSettle(const Duration(seconds: 3));
    await loginPage.login(validEmail, validPassword);
    await tester.pumpAndSettle(const Duration(seconds: 5));
    expect(loginPage.isOnHomePage(), true);

    // ── Navigate to Upload screen ──────────────────────────────────────────
    await uploadPage.goToUploadScreenFromHome();

    // ── Select audio (bypasses native file picker) ─────────────────────────
    await uploadPage.simulateAudioSelection(fileName: _testFileName);

    // Assert upload page is visible and all tabs are present
    expect(uploadPage.isOnUploadScreen(), true);
    expect(uploadPage.isAllTabsVisible(), true);

    // Assert auto-filled fields are not empty
    expect(uploadPage.isAutoFilledTitleNotEmpty(), true);
    expect(uploadPage.isAutoFilledArtistNotEmpty(), true);

    // ── Verify tabs are tappable ───────────────────────────────────────────
    await uploadPage.switchToTab('Advanced');
    await uploadPage.switchToTab('Permissions');
    await uploadPage.switchToTab('Track Info');

    // ── Edit the auto-filled title ─────────────────────────────────────────
    await uploadPage.enterTitle('test track');
    expect(uploadPage.isTitleValue('test track'), true);

    // ── Fill in optional fields ────────────────────────────────────────────
    await uploadPage.selectGenre('Folk');
    await uploadPage.addTag('#testing');
    await uploadPage.setDescription('Test Uploading');

    // ── Toggle privacy ─────────────────────────────────────────────────────
    await uploadPage.tapPrivate();
    await uploadPage.tapPublic();

    // ── Save and assert success ────────────────────────────────────────────
    await uploadPage.tapSave();
    await uploadPage.waitForUploadResult(maxSeconds: 30);
    expect(uploadPage.isSuccessMessageVisible(), true);
  });
}
