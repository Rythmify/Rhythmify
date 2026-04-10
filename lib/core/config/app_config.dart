/// Configuration constants for the app.
///
/// This file contains API keys, URLs, and other configuration values
/// that may differ between environments.
class AppConfig {
  /// reCAPTCHA v3 site key for invisible verification.
  ///
  /// **IMPORTANT**: Replace this with your actual reCAPTCHA v3 site key:
  /// 1. Go to https://www.google.com/recaptcha/admin
  /// 2. Create a new site or use existing one
  /// 3. Choose **reCAPTCHA v3** (not v2)
  /// 4. Add your domains (e.g., localhost, your app's domain)
  /// 5. Copy the Site Key and paste it here
  ///
  /// reCAPTCHA v3 is invisible - no user interaction required.
  /// It returns a score (0.0-1.0) indicating likelihood of being human.
  /// Backend should verify the token and check the score.
  ///
  /// Example: '6LeIxAcTAAAAAJcZVRqyHh71UMIEGNQ_MXjiZKhI' (test key)
  static const String recaptchaSiteKey =
      '6LfpEYksAAAAAJmvV1zFwxwJqBzdiLldbLg4JwHn'; // Google's official v3 test key

  /// Whether reCAPTCHA is enabled.
  ///
  /// Set to false to disable reCAPTCHA entirely (useful for testing).
  /// When false, the dev bypass token will be used instead.
  static const bool recaptchaEnabled = false;

  /// Test/Development reCAPTCHA v3 site key (provided by Google for testing).
  ///
  /// This key always returns a score. Use it for local development.
  /// See: https://developers.google.com/recaptcha/docs/faq
  static const String recaptchaTestSiteKey =
      '6LeIxAcTAAAAAJcZVRqyHh71UMIEGNQ_MXjiZKhI';

  /// Gets the appropriate site key based on environment.
  static String getRecaptchaSiteKey() {
    // In production, use the real key
    // In development, you can use the test key or real key depending on backend
    return recaptchaSiteKey;
  }
}
