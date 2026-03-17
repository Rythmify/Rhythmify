import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:rythmify/features/messaging/data/repositories/repository_implement_mock.dart';
import 'package:rythmify/features/messaging/domain/usecases/mark_messages_as_read_usecase.dart';
import 'package:rythmify/features/messaging/presentation/providers/conversations_provider.dart';
import 'package:rythmify/features/messaging/presentation/providers/messages_provider.dart';

class MarkAsReadNotifier extends StateNotifier<bool> {
  final Ref ref;
  MarkAsReadNotifier({
    required this.ref
  }):super(false);

  Future<void> markRead({
    required String msgId,
    required String convId,
  }) async{
    state =true;
    final repo=RepositoryImplementMock();
    final uCase=MarkMessagesAsReadUsecase(repo: repo);
    await uCase(msgId);
    ref.refresh(conversationProvider);
    ref.refresh(messageProvider(convId));
    state=false;
  }
}