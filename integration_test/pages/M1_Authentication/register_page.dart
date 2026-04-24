import 'package:flutter_test/flutter_test.dart';
import '../base_page.dart';
import '../../selectors/selectors.dart';

class RegisterPage extends BasePage {
  RegisterPage(WidgetTester tester) : super(tester);

  Future<void> enterEmail(String email) async {
    await enterTextByKey(authEmailTextField, email);
  }

  Future<void> tapContinue() async {
    await tapByKey(authContinueButton);
  }

  Future<void> enterPassword(String password) async {
    await enterTextByKey(authPasswordTextField, password);
  }

  Future<void> tapPasswordContinue() async {
    await tapByKey(authContinueElevatedButton);
  }

  Future<void> enterUsername(String username) async {
    await enterTextByKey(authRegisterUsernameTextField, username);
  }

  // DropdownButton opens all items in widget tree — just tap by text
  Future<void> selectMonth(String month) async {
    await tapByKey(authRegisterMonthDropdown);
    await scrollUntilVisible(itemText: month, scrollableKey: authRegisterMonthDropdown);
    await tester.tap(find.text(month).last);
    await tester.pumpAndSettle();
  }

  Future<void> selectDay(String day) async {
    await tapByKey(authRegisterDayDropdown);
    await scrollUntilVisible(itemText: day, scrollableKey: authRegisterDayDropdown);
    await tester.tap(find.text(day).last);
    await tester.pumpAndSettle();
  }

  Future<void> selectYear(String year) async {
    await tapByKey(authRegisterYearDropdown);
    await scrollUntilVisible(itemText: year, scrollableKey: authRegisterYearDropdown);
    await tester.tap(find.text(year).last);
    await tester.pumpAndSettle();
  }

  Future<void> selectGender(String gender) async {
    await tapByKey(authRegisterGenderDropdown);
    await tester.tap(find.text(gender).last);
    await tester.pumpAndSettle();
  }

  Future<void> tapFinalContinue() async {
    await tapByKey(authRegisterFinalContinueButton);
  }

  Future<void> register(
    String email,
    String password,
    String username,
    String month,
    String day,
    String year,
    String gender,
  ) async {
    await enterEmail(email);
    await tapContinue();
    await tester.pumpAndSettle();
    await enterPassword(password);
    await tapPasswordContinue();
    await tester.pumpAndSettle();
    await enterUsername(username);
    await selectMonth(month);
    await selectDay(day);
    await selectYear(year);
    await selectGender(gender);
    await tapFinalContinue();
  }

  bool isOnLoginPage() => isVisible(authTitleText);
  bool isOnHomePage() => isVisible(homeScaffold);
  bool isOnValidEmailPage() => isVisible(authVerifyEmailTitle);
  bool isEmailEmptyErrorVisible() => find.text('Please enter your email').evaluate().isNotEmpty;
  bool isInvalidEmailErrorVisible() => find.text('Please enter a valid email').evaluate().isNotEmpty;
  bool isPasswordEmptyErrorVisible() => find.text('Please enter a password').evaluate().isNotEmpty;
  bool isUsernameEmptyErrorVisible() => find.text('Please enter a display name').evaluate().isNotEmpty;
  bool isDateOfBirthEmptyErrorVisible() => find.text('Please select your date of birth').evaluate().isNotEmpty;
  bool isGenderEmptyErrorVisible() => find.text('Please select your gender').evaluate().isNotEmpty;
  bool isAgeRestrictionErrorVisible() => find.text('You must be at least 13 years old to register').evaluate().isNotEmpty;
  bool isAlreadyExistsErrorVisible() => find.text('An account with this email already exists.').evaluate().isNotEmpty;

  bool isSpecificPasswordErrorVisible(String errorKey) {
    const errorMessages = {
      'ERROR_PASSWORD_TOO_SHORT':    'Password must be at least 8 characters',
      'ERROR_PASSWORD_NO_UPPERCASE': 'Password must contain an uppercase letter',
      'ERROR_PASSWORD_NO_LOWERCASE': 'Password must contain a lowercase letter',
      'ERROR_PASSWORD_NO_NUMBER':    'Password must contain a number',
    };
      final message = errorMessages[errorKey];
      if (message == null) return false;
      return find.text(message).evaluate().isNotEmpty;
  }
}