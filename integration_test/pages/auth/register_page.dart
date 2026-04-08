import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import '../base_page.dart';
import '../../selectors/selectors.dart';

class RegisterPage extends BasePage {
  RegisterPage(WidgetTester tester) : super(tester);

  // ─── Email Field ───
  Future<void> enterEmail(String email) async {
    await enterTextByKey(authEmailTextField, email);
  }

  // ─── Continue Button ───
  Future<void> tapContinue() async {
    await tapByKey(authContinueButton);
  }

  // ─── Password Field ───
  Future<void> enterPassword(String password) async {
    await enterTextByKey(authPasswordTextField, password);
  }

  Future<void> tapPasswordContinue() async {
    await tapByKey(authContinueElevatedButton);
  }

  // ─── Username Field ───
  Future<void> enterUsername(String username) async {
    await enterTextByKey(authRegisterUsernameTextField, username);
  }

  // ─── Date Dropdowns ───
  Future<void> selectMonth(String month) async {
    await tapByKey(authRegisterMonthDropdown);
    await tester.pumpAndSettle();
    await tester.tap(find.text(month));
    await tester.pumpAndSettle();
  }

  Future<void> openDayDropdown() async {
    await tapByKey(authRegisterDayDropdown);
    await tester.pumpAndSettle();
  }

  Future<void> scrollToDay(String day) async {
    await tester.dragUntilVisible(
      find.text(day),
      find.byKey(const Key(authRegisterDayDropdown)),
      const Offset(0, -100),
    );
    await tester.pumpAndSettle();
  }

  Future<void> selectDay(String day) async {
    await openDayDropdown();
    await scrollToDay(day);
    await tester.tap(find.text(day));
    await tester.pumpAndSettle();
  }

  Future<void> openYearDropdown() async {
    await tapByKey(authRegisterYearDropdown);
    await tester.pumpAndSettle();
  }

  Future<void> scrollToYear(String year) async {
    await tester.dragUntilVisible(
      find.text(year),
      find.byKey(const Key(authRegisterYearDropdown)),
      const Offset(0, -100),
    );
    await tester.pumpAndSettle();
  }

  Future<void> selectYear(String year) async {
    await openYearDropdown();
    await scrollToYear(year);
    await tester.tap(find.text(year));
    await tester.pumpAndSettle();
  }

  // ─── Gender Dropdown ───
  Future<void> selectGender(String gender) async {
    await tapByKey(authRegisterGenderDropdown);
    await tester.pumpAndSettle();
    await tester.tap(find.text(gender));
    await tester.pumpAndSettle();
  }

  // ─── Final Continue Button ───
  Future<void> tapFinalContinue() async {
    await tapByKey(authRegisterFinalContinueButton);
  }

  // ─── Complete Registration Flow ───
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

  // ─── Visibility Check Methods ───
  bool isOnLoginPage() {
    return isVisible(authTitleText);
  }

  bool isOnHomePage() {
    return isVisible(homeScaffold);
  }

  bool isEmailEmptyErrorVisible() {
    return find.text('Please enter your email').evaluate().isNotEmpty;
  }

  bool isInvalidEmailErrorVisible() {
    return find.text('Please enter a valid email').evaluate().isNotEmpty;
  }

  bool isPasswordEmptyErrorVisible() {
    return find.text('Please enter your password').evaluate().isNotEmpty;
  }

  bool isPasswordTooShortErrorVisible() {
    return find.text('Password must be at least 8 characters').evaluate().isNotEmpty;
  }

  bool isPasswordNoUppercaseErrorVisible() {
    return find.text('Password must contain an uppercase letter').evaluate().isNotEmpty;
  }

  bool isPasswordNoLowercaseErrorVisible() {
    return find.text('Password must contain a lowercase letter').evaluate().isNotEmpty;
  }

  bool isPasswordNoNumberErrorVisible() {
    return find.text('Password must contain a number').evaluate().isNotEmpty;
  }

  bool isUsernameEmptyErrorVisible() {
    return find.text('Please enter a username').evaluate().isNotEmpty;
  }

  bool isDateOfBirthEmptyErrorVisible() {
    return find.text('Please enter your date of birth').evaluate().isNotEmpty;
  }

  bool isGenderEmptyErrorVisible() {
    return find.text('Please select a gender').evaluate().isNotEmpty;
  }

  bool isAgeRestrictionErrorVisible() {
    return find.text('You must be at least 13 years old').evaluate().isNotEmpty;
  }

  bool isAlreadyExistsErrorVisible() {
    return find.text('This email already exists').evaluate().isNotEmpty ||
        find.text('Email already exists').evaluate().isNotEmpty;
  }

  bool isSpecificPasswordErrorVisible(String errorKey) {
    // Map error keys to error messages
    const errorMessages = {
      'ERROR_PASSWORD_TOO_SHORT': 'Password must be at least 8 characters',
      'ERROR_PASSWORD_NO_UPPERCASE': 'Password must contain an uppercase letter',
      'ERROR_PASSWORD_NO_LOWERCASE': 'Password must contain a lowercase letter',
      'ERROR_PASSWORD_NO_NUMBER': 'Password must contain a number',
    };

    final message = errorMessages[errorKey];
    if (message == null) return false;

    return find.text(message).evaluate().isNotEmpty;
  }
}
