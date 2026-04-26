import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rythmify/features/authentication/presentation/providers/auth_provider.dart';
import 'package:rythmify/features/authentication/presentation/providers/auth_state.dart';
import 'package:rythmify/features/messaging/data/datasources/data_sources_sockets.dart';

final socketProvider = Provider<DataSourcesSockets>((ref) {
  // Watch only the user ID so this provider does NOT rebuild on silent token
  // refresh (which changes the token but not the identity). It only rebuilds
  // on actual login / logout.
  final userId = ref.watch(
    authProvider.select((s) => s is AuthAuthenticated ? s.user.id : null),
  );

  debugPrint('🔌 socketProvider rebuilt | userId=$userId');

  final socket = DataSourcesSockets();

  if (userId != null) {
    String getToken() {
      final current = ref.read(authProvider);
      return current is AuthAuthenticated ? (current.user.token ?? '') : '';
    }

    socket.connect(
      'https://rythmify-backend-dev.livelypebble-6b7965ef.uaenorth.azurecontainerapps.io',
      getToken,
    );

    // When the Dio interceptor silently refreshes the access token, proactively
    // reconnect the socket with the new token. This covers the case where the
    // socket failed its initial connection with an expired token and all
    // automatic reconnect attempts have already been exhausted.
    ref.listen(
      authProvider.select((s) => s is AuthAuthenticated ? s.user.token : null),
      (previous, next) {
        if (next != null && next.isNotEmpty && next != previous) {
          socket.reconnectWithToken(next);
        }
      },
    );

    //   final binding=WidgetsBinding.instance;
    //   final observer=_AppLifeCycleObserver(() => socket.reConnectIfNeeded(getToken));
    //   binding.addObserver(observer);
    //   ref.onDispose(() {
    //     binding.removeObserver(observer);
    //     socket.disconnect();
    //   });
    // } else {
    //   ref.onDispose(() => socket.disconnect());
  }
  ref.onDispose(() => socket.disconnect());
  return socket;
});

// class _AppLifeCycleObserver extends WidgetsBindingObserver {
//   final VoidCallback onResumed;
//   _AppLifeCycleObserver(this.onResumed);

//   @override
//   void didChangeAppLifecycleState(AppLifecycleState state) {
//      if (state == AppLifecycleState.resumed) {
//       onResumed();
//     }
//   }
// }
