import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:crypto/crypto.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

/// Handles Google OAuth 2.0 sign-in on Windows using a browser-based
/// Authorization Code flow with PKCE.
///
/// Returns a Google [idToken] string on success, or null if the user
/// cancelled or an error occurred.
class GoogleOAuthWindows {
  /// The Desktop OAuth 2.0 client ID from Google Cloud Console.
  final String clientId;

  /// Creates a [GoogleOAuthWindows] with the given [clientId].
  const GoogleOAuthWindows({required this.clientId});

  static const _scopes = 'openid email profile';
  static const _timeoutDuration = Duration(minutes: 5);

  String _generateCodeVerifier() {
    final random = Random.secure();
    final bytes = List<int>.generate(32, (_) => random.nextInt(256));
    return base64UrlEncode(bytes).replaceAll('=', '');
  }

  String _generateCodeChallenge(String verifier) {
    final bytes = utf8.encode(verifier);
    final digest = sha256.convert(bytes);
    return base64UrlEncode(digest.bytes).replaceAll('=', '');
  }

  /// Opens the system browser for Google sign-in and returns the
  /// Google id_token on success, or null on cancellation/error.
  Future<String?> signIn() async {
    final codeVerifier = _generateCodeVerifier();
    final codeChallenge = _generateCodeChallenge(codeVerifier);

    // Bind to port 0 to get a free port assigned by the OS
    final server = await HttpServer.bind(
      InternetAddress.loopbackIPv4,
      0,
      shared: false,
    );
    final port = server.port;
    final redirectUri = 'http://localhost:$port';

    final authUrl = Uri.https('accounts.google.com', '/o/oauth2/v2/auth', {
      'client_id': clientId,
      'redirect_uri': redirectUri,
      'response_type': 'code',
      'scope': _scopes,
      'code_challenge': codeChallenge,
      'code_challenge_method': 'S256',
      'prompt': 'select_account',
    });

    // Open the browser
    if (!await launchUrl(authUrl, mode: LaunchMode.externalApplication)) {
      await server.close(force: true);
      return null;
    }

    // Wait for the callback with a timeout
    String? authCode;
    try {
      authCode = await _waitForCallback(server, port).timeout(_timeoutDuration);
    } on TimeoutException {
      await server.close(force: true);
      return null;
    }

    if (authCode == null) return null;

    // Exchange code for tokens
    return _exchangeCodeForIdToken(
      authCode: authCode,
      codeVerifier: codeVerifier,
      redirectUri: redirectUri,
    );
  }

  Future<String?> _waitForCallback(HttpServer server, int port) async {
    final completer = Completer<String?>();

    server.listen((HttpRequest request) async {
      final code = request.uri.queryParameters['code'];
      final error = request.uri.queryParameters['error'];

      request.response
        ..statusCode = 200
        ..headers.contentType = ContentType.html
        ..write('''
          <html><body style="font-family:sans-serif;text-align:center;
          padding-top:60px;background:#111;color:#fff">
          <h2>✓ Signed in successfully</h2>
          <p>You can close this tab and return to Rythmify.</p>
          </body></html>
        ''');
      await request.response.close();
      await server.close(force: true);

      if (!completer.isCompleted) {
        completer.complete(error != null ? null : code);
      }
    });

    return completer.future;
  }

  Future<String?> _exchangeCodeForIdToken({
    required String authCode,
    required String codeVerifier,
    required String redirectUri,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('https://oauth2.googleapis.com/token'),
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: {
          'code': authCode,
          'client_id': clientId,
          'redirect_uri': redirectUri,
          'code_verifier': codeVerifier,
          'grant_type': 'authorization_code',
        },
      );

      if (response.statusCode != 200) return null;

      final json = jsonDecode(response.body) as Map<String, dynamic>;
      return json['id_token'] as String?;
    } catch (_) {
      return null;
    }
  }
}
