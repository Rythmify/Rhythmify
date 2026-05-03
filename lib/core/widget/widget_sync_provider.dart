import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:home_widget/home_widget.dart';
import 'player_widget_updater.dart';
import '../../features/player/presentation/providers/player_provider.dart';
import '../../features/player/domain/entities/player_state.dart';
import '../../features/track/presentation/providers/track_interaction_provider.dart';
import '../routing/app_router.dart';

final widgetSyncProvider = NotifierProvider<WidgetSyncNotifier, void>(
  WidgetSyncNotifier.new,
);

/// Keeps the home screen widget in sync with the app's player state and
/// handles actions sent back from the widget (like, open player).
class WidgetSyncNotifier extends Notifier<void> {
  @override
  void build() {
    ref.listen<AppPlayerState>(playerStateProvider, (_, next) {
      _push(next);
    });

    final sub = HomeWidget.widgetClicked.listen(_onWidgetAction);
    ref.onDispose(sub.cancel);

    // Handle the URI if the app was cold-launched by tapping the widget
    HomeWidget.initiallyLaunchedFromHomeWidget().then((uri) {
      if (uri != null) _onWidgetAction(uri);
    });
  }

  void _push(AppPlayerState playerState) {
    final track = playerState.currentTrack;
    if (track == null) return;

    PlayerWidgetUpdater.update(
      trackTitle: track.title,
      artistName: track.artist,
      isPlaying: playerState.status == PlayerStatus.playing,
      isLiked: track.isLiked,
      artUrl: track.coverImage,
    ).ignore();
  }

  void _onWidgetAction(Uri? uri) {
    if (uri == null) return;

    if (uri.scheme == 'rythmify' && uri.host == 'widget') {
      final action = uri.queryParameters['action'];
      if (action == 'like') _handleLike();
    } else if (uri.scheme == 'rythmify' && uri.host == 'player') {
      ref.read(routerProvider).push('/player');
    }
  }

  void _handleLike() {
    final track = ref.read(playerStateProvider).currentTrack;
    if (track == null) return;

    // Optimistically flip the widget icon before the API responds
    HomeWidget.saveWidgetData<bool>('is_liked', !track.isLiked).then((_) {
      HomeWidget.updateWidget(androidName: 'PlayerWidget').ignore();
    });

    ref
        .read(trackInteractionProvider)
        .handleToggleLike(track.id, track.isLiked, currentTrack: track);
  }
}
