/// Holds Google Sign-In credentials to pre-fill the registration form.
///
/// This entity is used when a user signs in with Google but needs to complete
/// registration. It carries the Google credential and profile data from the
/// Google Sign-In flow to the registration screen.
///
/// The flow is:
/// 1. User taps "Continue with Google" on sign-in page
/// 2. Google Sign-In opens and user authenticates
/// 3. This entity is populated with Google data
/// 4. User is navigated to registration page with this data
/// 5. Registration form pre-fills fields from this entity
/// 6. On submit, registration calls `POST /auth/google` with the `idToken`
class GoogleAuthData {
  /// The Google ID token to be sent to the backend after registration.
  ///
  /// This token is obtained from [GoogleSignInAuthentication] after
  /// successful Google Sign-In. It's sent to `POST /auth/google` to
  /// authenticate the user account creation.
  final String idToken;

  /// Pre-filled email from Google account.
  ///
  /// The email associated with the Google account that signed in.
  /// On the registration form, this field is read-only to ensure
  /// the user registers with their Google-associated email.
  final String email;

  /// Pre-filled display name from Google account.
  ///
  /// The name from the Google account profile. If not provided by Google,
  /// this may be null. Used to pre-fill the "Display Name" field on
  /// the registration form.
  final String? displayName;

  /// Google profile photo URL for avatar preview.
  ///
  /// The profile picture URL from the Google account. If provided,
  /// this can be displayed as an avatar preview on the registration form.
  /// Can be null if the Google account has no profile picture.
  final String? photoUrl;

  /// Creates a [GoogleAuthData] instance.
  ///
  /// All parameters except [idToken] and [email] are optional.
  const GoogleAuthData({
    required this.idToken,
    required this.email,
    this.displayName,
    this.photoUrl,
  });
}
