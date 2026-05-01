import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:rythmify/features/messaging/domain/usecases/unblock_user_usecase.dart';
import 'package:rythmify/features/messaging/presentation/providers/conversations_provider.dart';
import 'package:rythmify/features/messaging/presentation/providers/is_blocked_provider.dart';
import 'package:rythmify/features/messaging/presentation/providers/repository_provider.dart';

class UnblockNotifier extends StateNotifier<bool> {
  final Ref ref;
  UnblockNotifier({required this.ref}) : super(false);

  Future<void> unBlockUser({required String participantId}) async {
    if (!mounted) return;
    state = true;
    final uCase = UnblockUserUsecase(repo: ref.read(repositoryprovider));
    await uCase(participantId);
    if (!mounted) return;
    state = false;
    ref.invalidate(isBlockedProvider(participantId));
    ref.invalidate(conversationProvider);
  }
}
