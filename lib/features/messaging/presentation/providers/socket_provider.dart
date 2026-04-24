import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rythmify/features/authentication/presentation/providers/auth_provider.dart';
import 'package:rythmify/features/authentication/presentation/providers/auth_state.dart';
import 'package:rythmify/features/messaging/data/datasources/data_sources_sockets.dart';

final socketProvider = Provider<DataSourcesSockets>((ref) {
  final authState = ref.read(authProvider);
  final token = authState is AuthAuthenticated ? authState.user.token : null;
  final socket = DataSourcesSockets();

  if (token != null) {
    socket.connect(
      'https://rythmify-backend-dev.livelypebble-6b7965ef.uaenorth.azurecontainerapps.io',
      token,
    );
  } else {
    //print('⚠️ socketProvider: no token, socket not connected');
  }

  ref.onDispose(() => socket.disconnect());

  return socket;
});
