/// Holds the result returned by the backend after a successful GitHub OAuth flow.
class GitHubAuthData {
  /// JWT access token for subsequent API calls.
  final String accessToken;

  /// Whether this is a brand-new Rythmify account created via GitHub.
  final bool isNewUser;

  /// Creates a [GitHubAuthData] instance.
  const GitHubAuthData({required this.accessToken, required this.isNewUser});

  /// Deserializes from the `data` object in the backend login response.
  factory GitHubAuthData.fromJson(Map<String, dynamic> json) {
    return GitHubAuthData(
      accessToken: json['access_token'] as String,
      isNewUser: json['is_new_user'] as bool? ?? false,
    );
  }
}
