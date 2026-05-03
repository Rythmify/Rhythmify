import 'package:home_widget/home_widget.dart';

class LikesWidgetUpdater {
  static const String _androidWidgetName = 'LikesWidget';

  static Future<void> update({
    required List<({String id, String? artUrl})> tracks,
    required String userId,
    String? pfpUrl,
  }) async {
    await HomeWidget.saveWidgetData<int>('likes_track_count', tracks.length);
    for (int i = 0; i < tracks.length && i < 5; i++) {
      await HomeWidget.saveWidgetData<String>(
        'likes_track_${i}_id',
        tracks[i].id,
      );
      if (tracks[i].artUrl != null) {
        await HomeWidget.saveWidgetData<String>(
          'likes_track_${i}_art',
          tracks[i].artUrl!,
        );
      }
    }
    await HomeWidget.saveWidgetData<String>('likes_user_id', userId);
    if (pfpUrl != null) {
      await HomeWidget.saveWidgetData<String>('likes_pfp_url', pfpUrl);
    }
    await HomeWidget.updateWidget(androidName: _androidWidgetName);
  }
}
