import 'package:flutter_test/flutter_test.dart';
//import 'package:flutter/material.dart';
import '../base_page.dart';
import '../../selectors/selectors.dart';

class LoginPage extends BasePage {

  LoginPage(super.tester);

  Future<void> enterEmail(String email) async {
    await enterTextByKey(authEmailTextField, email);
  }

  Future<void> tapContinue() async {
    await tapByKey(authContinueButton);
  }

  Future<void> enterPassword(String password) async {
    await enterTextByKey(authLoginPasswordAuthTextField, password);
  }

  Future<void> tapLogin() async {
    await tapByKey(authLoginPasswordSignInElevatedButton);
  }

  Future<void> tapGoogleSignIn() async {
    await tapByKey(authSocialGoogleButton);
  }

  Future<void> tapAppleSignIn() async {
    await tapByKey(authSocialAppleButton);
  }

  Future<void> tapFacebookSignIn() async {
    await tapByKey(authSocialFacebookButton);
  }

  Future<void> tapPasswordBack() async {
    await tapByKey(authLoginPasswordBackButton);
  }

  Future<void> login(String email, String password) async {
    await enterEmail(email);
    await tapContinue();
    await tester.pumpAndSettle();
    await enterPassword(password);
    await tapLogin();
  }

  bool isOnLoginPage() {
    return isVisible(authTitleText);
  }

  bool isOnPasswordPage() {
    return isVisible(authLoginPasswordEmailDisplayText);
  }

  bool isOnHomePage() {
    return isVisible(homeScaffold);
  }
}