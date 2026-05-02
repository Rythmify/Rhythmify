import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:home_widget/home_widget.dart';
import 'likes_widget_updater.dart';
import '../../features/authentication/presentation/providers/auth_provider.dart';
import '../../features/authentication/presentation/providers/auth_state.dart';
import '../../features/library/presentation/providers/library_providers.dart';
import '../routing/app_router.dart';

final likesWidgetSyncProvider = NotifierProvider<LikesWidgetSyncNotifier, void>(
  LikesWidgetSyncNotifier.new,
);

class LikesWidgetSyncNotifier extends Notifier<void> {
  @override
  void build() {
    // Push immediately if auth + likes are already ready (covers re-init after hot restart)
    _maybePushCurrent();

    ref.listen<LikesState>(likesProvider, (_, next) {
      _push(next);
    });

    // When auth becomes ready AFTER likes have already loaded, push the cached state
    ref.listen<AuthState>(authProvider, (_, next) {
      if (next is AuthAuthenticated) {
        _push(ref.read(likesProvider));
      }
    });

    // final sub = HomeWidget.widgetClicked.listen(_onWidgetAction);
    // ref.onDispose(sub.cancel);

    // HomeWidget.initiallyLaunchedFromHomeWidget().then((uri) {
    //   if (uri != null) _onWidgetAction(uri);
    // });
  }

  void _maybePushCurrent() {
    final auth = ref.read(authProvider);
    if (auth is! AuthAuthenticated) return;
    final likes = ref.read(likesProvider);
    if (likes.tracks.isNotEmpty) _push(likes);
  }

  void _push(LikesState state) {
    final authState = ref.read(authProvider);
    if (authState is! AuthAuthenticated) return;

    final tracks = state.tracks
        .take(5)
        .map((t) => (id: t.id, artUrl: t.artworkUrl))
        .toList();

    LikesWidgetUpdater.update(
      tracks: tracks,
      userId: authState.user.id,
      pfpUrl: authState.user.avatarUrl,
    ).ignore();
  }

  // void _onWidgetAction(Uri? uri) {
  //   if (uri == null) return;
  //   if (uri.scheme != 'rythmify') return;

  //   // Ignore URIs meant for the player widget
  //   if (uri.host == 'widget' || uri.host == 'player') return;

  //   final router = ref.read(routerProvider);

  //   // go() is required here — push() targets the current branch's navigator,
  //   // which may not own routes in other StatefulShellBranch tabs.
  //   switch (uri.host) {
  //     case 'likes_open':
  //       router.go('/library/likes');

  //     case 'likes_profile':
  //       final userId = uri.queryParameters['userId'];
  //       if (userId != null && userId.isNotEmpty) {
  //         router.go('/home/profile/$userId');
  //       }

  //     case 'likes_track':
  //       final trackId = uri.queryParameters['id'];
  //       if (trackId != null && trackId.isNotEmpty) {
  //         router.go('/home/behind-the-track/$trackId');
  //       }
  //   }
  // }
}
