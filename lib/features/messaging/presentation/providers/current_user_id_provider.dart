import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rythmify/features/authentication/presentation/providers/auth_provider.dart';
import 'package:rythmify/features/authentication/presentation/providers/auth_state.dart';

/// Provides the ID of the currently authenticated user.
///
/// In this mock implementation, it returns 'current_user' to match the ID
/// used in [MockDatasourceImplement] for messages sent by the user.

bool mock = true;
final currentUserIdProvider = Provider<String>((ref) {
  if (mock) {
    return 'current_user';
  } else {
    final authState = ref.watch(authProvider);
    if (authState is AuthAuthenticated) {
      return authState.user.id;
    }
    return '';
  }
});
