import 'package:flutter/services.dart';

/// Asks the launcher to show the native "Add to Home screen?" pin dialog
/// for the player widget. Uses the same method channel as dynamic icons.
class WidgetPinService {
  static const _channel = MethodChannel('flutter_dynamic_icon');

  /// Returns `true` if the dialog was shown, `false` if the launcher does not
  /// support widget pinning (older launchers or Android < 8).
  static Future<bool> requestPin() async {
    try {
      return await _channel.invokeMethod<bool>('pinWidget') ?? false;
    } on PlatformException {
      return false;
    }
  }

  static Future<bool> requestPinLikes() async {
    try {
      return await _channel.invokeMethod<bool>('pinLikesWidget') ?? false;
    } on PlatformException {
      return false;
    }
  }
}
