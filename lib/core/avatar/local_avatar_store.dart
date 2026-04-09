import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _localAvatarPrefix = 'local_avatar_path_';
const _localCoverPrefix = 'local_cover_path_';

final localAvatarPathProvider = FutureProvider.family<String?, String>((
  _,
  userId,
) async {
  return LocalAvatarStore.get(userId);
});

final localCoverPathProvider = FutureProvider.family<String?, String>((
  _,
  userId,
) async {
  return LocalAvatarStore.getCover(userId);
});

class LocalAvatarStore {
  static String _key(String userId) => '$_localAvatarPrefix$userId';

  static Future<void> set(String userId, String filePath) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key(userId), filePath);
  }

  static Future<String?> get(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_key(userId));
  }

  static Future<void> clear(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key(userId));
  }

  static String _coverKey(String userId) => '$_localCoverPrefix$userId';

  static Future<void> setCover(String userId, String filePath) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_coverKey(userId), filePath);
  }

  static Future<String?> getCover(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_coverKey(userId));
  }

  static Future<void> clearCover(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_coverKey(userId));
  }
}
