import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import '../base_page.dart';
import '../../selectors/selectors.dart';

class ProfilePage extends BasePage {
  ProfilePage(WidgetTester tester) : super(tester);

  // ── Navigation to Profile ──

  /// Taps the Library tab in the bottom navigation bar.
  Future<void> goToLibraryTab() async {
    await tester.tap(find.text('Library'));
    await tester.pumpAndSettle(const Duration(seconds: 2));
  }

  /// Taps the account avatar in the Library screen header.
  Future<void> tapProfileAvatar() async {
    await tapByKey(libraryProfileAvatarGesture);
  }

  // ── Public Profile Page ──
  /// True when the public profile page is active (back button in AppBar visible).
  bool isOnProfilePage() => isVisible(publicProfileBackButton);

  /// True when the own profile has fully loaded (edit icon and play button visible).
  bool isProfileDataVisible() {
    return isVisible(publicProfileEditGesture) &&
        isVisible(publicProfilePlayButton);
  }

  /// True when a text widget with [name] exists anywhere in the widget tree.
  bool isProfileNameVisible(String name) {
    return find.text(name).evaluate().isNotEmpty;
  }

  /// Taps the edit pencil icon to navigate to the Edit Profile page.
  Future<void> tapEdit() async {
    await tapByKey(publicProfileEditGesture);
  }

  // ── Edit Profile Page ──

  /// True when the Edit Profile page is active (Save button in AppBar visible).
  bool isOnEditProfilePage() => isVisible(editProfileSaveButton);

  /// Replaces the display name field content with [name].
  Future<void> enterName(String name) async {
    await enterTextByKey(editProfileNameTextField, name);
  }

  Future<void> enterUsername(String name) async {
    await enterTextByKey(editProfileUsernameTextField , name);
  }

  Future<void> enterFirstname(String name) async {
    await enterTextByKey(editProfileFirstNameTextField , name);
  }

  Future<void> enterLastname(String name) async {
    await enterTextByKey(editProfileLastNameTextField , name);
  }

  /// Replaces the city field content with [city].
  Future<void> enterCity(String city) async {
    await enterTextByKey(editProfileCityTextField, city);
  }

  /// Opens the country picker bottom sheet.
  Future<void> tapCountryField() async {
    await tester.dragUntilVisible(
      find.byKey(Key(editProfileCountryGesture)),
      find.byKey(Key(editProfileScrollView)),
      const Offset(0, -100),
    );
    await tester.pump();
    await tester.tap(find.byKey(Key(editProfileCountryGesture)));
    // Use explicit pumps instead of pumpAndSettle — continuous animations can
    // prevent pumpAndSettle from settling, causing it to return before the
    // modal bottom sheet is in the widget tree.
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    await tester.pump(const Duration(milliseconds: 300));
  }

  /// Scrolls the country picker list until [countryName] is visible, then taps it.
  Future<void> selectCountry(String countryName) async {
    await tester.dragUntilVisible(
      find.text(countryName),
      find.byKey(const Key(editProfileCountryListView)),
      const Offset(0, -100),
      maxIteration: 100,
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text(countryName));
    await tester.pumpAndSettle();
  }

  /// Opens the bio editor bottom sheet.
  /// Scrolls the form until the bio field is visible above the keyboard,
  /// then taps it.
  Future<void> tapBioField() async {
    await tester.dragUntilVisible(
      find.byKey(Key(editProfileBioGesture)),
      find.byKey(Key(editProfileScrollView)),
      const Offset(0, -100),
    );
    await tester.pump(const Duration(milliseconds: 300));
    await tester.tap(find.byKey(Key(editProfileBioGesture)));
    await tester.pumpAndSettle();
  }

  /// Replaces the bio text field content (inside the bottom sheet) with [bio].
  Future<void> enterBio(String bio) async {
    await enterTextByKey(editProfileBioTextField, bio);
  }

  /// Taps the Done button to close the bio editor bottom sheet.
  Future<void> tapBioDone() async {
    await tapByKey(editProfileBioDoneButton);
  }

  /// Taps the Save button in the Edit Profile AppBar.
  Future<void> tapSave() async {
    await tapByKey(editProfileSaveButton);
  }

  /// Taps the back arrow in the Edit Profile AppBar.
  Future<void> tapBack() async {
    await tapByKey(editProfileBackButton);
  }

  // ── Unsaved Changes Dialog ──

  /// True when the "Are you sure?" unsaved-changes dialog is showing.
  bool isUnsavedChangesDialogVisible() {
    return isVisible(profileUnsavedChangesDiscard) &&
        isVisible(profileUnsavedChangesContinue);
  }

  /// Taps "CONTINUE EDITING" in the unsaved-changes dialog (stays on edit page).
  Future<void> tapContinueEditing() async {
    await tapByKey(profileUnsavedChangesContinue);
  }

  /// Taps "DISCARD CHANGES" in the unsaved-changes dialog (navigates away).
  Future<void> tapDiscardChanges() async {
    await tapByKey(profileUnsavedChangesDiscard);
  }

  Future<void> scrollUpUntilVisible(String key) async {
  await tester.dragUntilVisible(
    find.byKey(Key(key)),
    find.byKey(const Key(homeScrollView)),
    const Offset(0, 500), 
    maxIteration: 50,
  );
  await tester.pumpAndSettle(); 
}
}
