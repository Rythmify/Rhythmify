import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import '../base_page.dart';
import '../../selectors/selectors.dart';

class ProfilePage extends BasePage {
  ProfilePage(WidgetTester tester) : super(tester);

  Future<void> goToLibraryTab() async {
    await tester.tap(find.text('Library'));
    await tester.pumpAndSettle(const Duration(seconds: 2));
  }

  Future<void> tapProfileAvatar() async {
    await tapByKey(libraryProfileAvatarGesture);
  }


  bool isOnProfilePage() => isVisible(publicProfileBackButton);

  bool isProfileDataVisible() {
    return isVisible(publicProfileEditGesture) &&
        isVisible(publicProfilePlayButton);
  }

  bool isProfileNameVisible(String name) {
    return find.text(name).evaluate().isNotEmpty;
  }

  Future<void> tapEdit() async {
    await tapByKey(publicProfileEditGesture);
  }

  bool isOnEditProfilePage() => isVisible(editProfileSaveButton);

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

  Future<void> enterCity(String city) async {
    await enterTextByKey(editProfileCityTextField, city);
  }

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

  Future<void> enterBio(String bio) async {
    await enterTextByKey(editProfileBioTextField, bio);
  }

  Future<void> tapBioDone() async {
    await tapByKey(editProfileBioDoneButton);
  }

  Future<void> tapSave() async {
    await tapByKey(editProfileSaveButton);
  }

  Future<void> tapBack() async {
    await tapByKey(editProfileBackButton);
  }

  bool isUnsavedChangesDialogVisible() {
    return isVisible(profileUnsavedChangesDiscard) &&
        isVisible(profileUnsavedChangesContinue);
  }

  Future<void> tapContinueEditing() async {
    await tapByKey(profileUnsavedChangesContinue);
  }

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
