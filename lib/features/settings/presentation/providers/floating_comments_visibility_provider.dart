import 'package:flutter_riverpod/legacy.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FloatingCommentsVisibilityNotifier extends StateNotifier<bool> {
  static const _prefKey = 'show_waveform_comments';

  FloatingCommentsVisibilityNotifier() : super(true) {
    _init();
  }

  Future<void> _init() async {
    final prefs = await SharedPreferences.getInstance();
    if (mounted) state = prefs.getBool(_prefKey) ?? true;
  }

  Future<void> set(bool value) async {
    state = value;
    final prefs = await SharedPreferences.getInstance();
    prefs.setBool(_prefKey, value);
  }
}

final floatingCommentsVisibilityProvider =
    StateNotifierProvider<FloatingCommentsVisibilityNotifier, bool>(
      (_) => FloatingCommentsVisibilityNotifier(),
    );
