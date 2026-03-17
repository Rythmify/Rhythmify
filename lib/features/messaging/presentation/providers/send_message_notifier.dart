import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:rythmify/features/messaging/data/repositories/repository_implement_mock.dart';
import 'package:rythmify/features/messaging/domain/entities/message.dart';
import 'package:rythmify/features/messaging/domain/usecases/send_message_usecase.dart';
import 'package:rythmify/features/messaging/presentation/providers/conversations_provider.dart';
import 'package:rythmify/features/messaging/presentation/providers/messages_provider.dart';

class SendMessageNotifier extends StateNotifier<bool> {
  final Ref ref;

  SendMessageNotifier({
    required this.ref
  }):super(false);

  Future<void> sendMessage({
    required Message msg
  }) async{
    state=true;
    final repo=RepositoryImplementMock();
    final uCase=SendMessageUsecase(repo: repo);
    await(uCase(msg));
    ref.refresh(conversationProvider);
    ref.refresh(messageProvider(msg.conversationId));
    state=false;
  }

}