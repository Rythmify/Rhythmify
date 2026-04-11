import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:rythmify/main.dart' as app;
import '../../pages/M1_Authentication/login_page.dart';
import '../../pages/M2_Profile/profile_page.dart';
import '../../fixtures/test_data.dart';
import '../../selectors/selectors.dart';


void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('M2 - Profile - all scenarios', (tester) async {
    app.main();
    await tester.pumpAndSettle(const Duration(seconds: 5));

    // ── Login first ──
    final loginPage = LoginPage(tester);
    await tester.tap(find.byKey(const Key(onboardingLoginButton)));
    await tester.pumpAndSettle(const Duration(seconds: 3));
    await loginPage.login(validEmail, validPassword);
    await tester.pumpAndSettle(const Duration(seconds: 5));

    expect(loginPage.isOnHomePage(), true);

    final profilePage = ProfilePage(tester);

    // ── Navigate: Home → Library tab → Account icon ──
    await profilePage.goToLibraryTab();
    await profilePage.tapProfileAvatar();
    await tester.pumpAndSettle(const Duration(seconds: 3));

    // ─── TC-PROFILE-001 | Profile page loads with user data ───────────────
    expect(profilePage.isOnProfilePage(), true);
    expect(profilePage.isProfileDataVisible(), true);

    // ─── TC-PROFILE-002 | Edit name, city, country, bio — verify saved ────
    await profilePage.tapEdit();
    await tester.pumpAndSettle(const Duration(seconds: 2));
    expect(profilePage.isOnEditProfilePage(), true);

    await profilePage.enterName(profileEditNewName);
    await profilePage.enterCity(profileEditNewCity);

    await profilePage.tapCountryField();
    await tester.pump(const Duration(milliseconds: 500));
    await profilePage.selectCountry(profileEditNewCountryName);
    await tester.tap(find.byType(Scaffold)); 
    await tester.pumpAndSettle();

    await profilePage.tapBioField();
    await tester.pumpAndSettle();
    await profilePage.enterBio(profileEditNewBio);
    await profilePage.tapBioDone();

    await profilePage.tapSave();
    await tester.pumpAndSettle(const Duration(seconds: 4));

    expect(profilePage.isOnProfilePage(), true);
    expect(profilePage.isProfileNameVisible(profileEditNewName), true);

    // ─── TC-PROFILE-003 | Edit → Back → Continue Editing (stay on edit) ───
    await profilePage.tapEdit();
    await tester.pumpAndSettle(const Duration(seconds: 2));
    await profilePage.enterName('Continue editing test');

    await profilePage.tapBack();
    await tester.pumpAndSettle();
    expect(profilePage.isUnsavedChangesDialogVisible(), true);

    await profilePage.tapContinueEditing();
    await tester.pumpAndSettle();
    await profilePage.enterName(profileEditNewName);
    await profilePage.tapSave();
    await tester.pumpAndSettle(const Duration(seconds: 4));

    expect(profilePage.isOnProfilePage(), true);
    expect(profilePage.isProfileNameVisible(profileEditNewName), true);

    // ─── TC-PROFILE-004 | Edit → Back → Discard Changes (back to profile) ─
    await profilePage.tapEdit();
    await tester.pumpAndSettle(const Duration(seconds: 2));
    await profilePage.enterName('Discard changes test');

    await profilePage.tapBack();
    await tester.pumpAndSettle();
    expect(profilePage.isUnsavedChangesDialogVisible(), true);

    await profilePage.tapDiscardChanges();
    await tester.pumpAndSettle();
    expect(profilePage.isOnProfilePage(), true);
    expect(profilePage.isProfileNameVisible(profileEditNewName), true);
  });
}
