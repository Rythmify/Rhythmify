import 'package:home_widget/home_widget.dart';

/// Pushes current player state to the Android home screen widget.
///
/// Call [update] whenever the track or play state changes.
/// The widget reads the saved values when the OS triggers its next draw.
class PlayerWidgetUpdater {
  static const String _androidWidgetName = 'PlayerWidget';

  static Future<void> update({
    required String trackTitle,
    required String artistName,
    required bool isPlaying,
    required bool isLiked,
    String? artUrl,
  }) async {
    await HomeWidget.saveWidgetData<String>('track_title', trackTitle);
    await HomeWidget.saveWidgetData<String>('artist_name', artistName);
    await HomeWidget.saveWidgetData<bool>('is_playing', isPlaying);
    await HomeWidget.saveWidgetData<bool>('is_liked', isLiked);
    if (artUrl != null) {
      await HomeWidget.saveWidgetData<String>('art_url', artUrl);
    }
    await HomeWidget.updateWidget(androidName: _androidWidgetName);
  }
}
