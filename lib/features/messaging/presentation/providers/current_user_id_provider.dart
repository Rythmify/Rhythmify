import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Provides the ID of the currently authenticated user.
///
/// In this mock implementation, it returns 'current_user' to match the ID
/// used in [MockDatasourceImplement] for messages sent by the user.
final currentUserIdProvider = Provider<String>((ref) {
  return 'current_user';
});
