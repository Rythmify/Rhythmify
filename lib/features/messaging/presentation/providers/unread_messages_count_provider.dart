import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rythmify/features/messaging/presentation/providers/conversations_provider.dart';

final unreadMessagesCountProvider = Provider<int>((ref) {
  return ref
      .watch(conversationProvider)
      .maybeWhen(
        data: (convs) => convs.fold(0, (sum, c) => sum + c.unReadCount),
        orElse: () => 0,
      );
});
