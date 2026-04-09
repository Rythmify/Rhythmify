import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../../../../core/config/app_config.dart';

/// Invisible reCAPTCHA v3 verification service.
///
/// reCAPTCHA v3 is invisible and runs in the background without user interaction.
/// It returns a score (0.0-1.0) indicating the likelihood that the user is human.
///
/// Usage:
/// ```dart
/// final token = await RecaptchaV3Service.execute(action: 'register');
/// // Send token to backend for verification
/// ```
class RecaptchaV3Service {
  /// Executes reCAPTCHA v3 verification and returns a token.
  ///
  /// [action] - The action name for this verification (e.g., 'register', 'login').
  ///            Backend can use this to apply different score thresholds.
  ///
  /// Returns the reCAPTCHA token string, or null on failure.
  static Future<String?> execute({
    required String action,
    required BuildContext context,
  }) async {
    try {
      final completer = await showDialog<String?>(
        context: context,
        barrierDismissible: false,
        barrierColor: Colors.transparent, // Invisible
        builder: (context) => _RecaptchaV3Dialog(action: action),
      );
      return completer;
    } catch (e) {
      debugPrint('reCAPTCHA v3 error: $e');
      return null;
    }
  }
}

/// Invisible dialog that executes reCAPTCHA v3 in a hidden WebView.
class _RecaptchaV3Dialog extends StatefulWidget {
  final String action;

  const _RecaptchaV3Dialog({required this.action});

  @override
  State<_RecaptchaV3Dialog> createState() => _RecaptchaV3DialogState();
}

class _RecaptchaV3DialogState extends State<_RecaptchaV3Dialog> {
  late final WebViewController _webViewController;

  @override
  void initState() {
    super.initState();
    _initializeWebView();
  }

  void _initializeWebView() {
    _webViewController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.transparent)
      ..addJavaScriptChannel(
        'RecaptchaV3',
        onMessageReceived: (JavaScriptMessage message) {
          // Token received from reCAPTCHA v3
          if (mounted) {
            Navigator.of(context).pop(message.message);
          }
        },
      )
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageFinished: (String url) {
            // reCAPTCHA v3 executes automatically on page load
          },
          onWebResourceError: (WebResourceError error) {
            if (mounted) {
              Navigator.of(context).pop(null);
            }
          },
        ),
      )
      ..loadRequest(
        Uri.dataFromString(
          _getRecaptchaV3Html(),
          mimeType: 'text/html',
          encoding: Encoding.getByName('utf-8'),
        ),
      );
  }

  String _getRecaptchaV3Html() {
    final siteKey = AppConfig.getRecaptchaSiteKey();
    final action = widget.action;

    return '''
    <!DOCTYPE html>
    <html>
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <script src="https://www.google.com/recaptcha/api.js?render=$siteKey"></script>
        <style>
            body {
                margin: 0;
                padding: 0;
                background: transparent;
            }
        </style>
    </head>
    <body>
        <script>
            grecaptcha.ready(function() {
                grecaptcha.execute('$siteKey', { action: '$action' })
                    .then(function(token) {
                        // Send token back to Flutter
                        if (window.RecaptchaV3) {
                            window.RecaptchaV3.postMessage(token);
                        }
                    })
                    .catch(function(error) {
                        console.error('reCAPTCHA error:', error);
                        if (window.RecaptchaV3) {
                            window.RecaptchaV3.postMessage('error');
                        }
                    });
            });
        </script>
    </body>
    </html>
    ''';
  }

  @override
  Widget build(BuildContext context) {
    // Invisible dialog - reCAPTCHA v3 WebView runs in background
    return SizedBox.shrink(
      child: Offstage(child: WebViewWidget(controller: _webViewController)),
    );
  }
}
