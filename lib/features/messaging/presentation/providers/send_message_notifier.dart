import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:rythmify/features/messaging/domain/entities/conversation.dart';
import 'package:rythmify/features/messaging/domain/usecases/ensure_conversation_usecase.dart';
import 'package:rythmify/features/messaging/domain/usecases/send_message_usecase.dart';
import 'package:rythmify/features/messaging/domain/usecases/start_conversation_usecase.dart';
import 'package:rythmify/features/messaging/presentation/providers/conversations_provider.dart';
import 'package:rythmify/features/messaging/presentation/providers/messages_notifier.dart';
import 'package:rythmify/features/messaging/presentation/providers/repository_provider.dart';
import 'package:rythmify/features/messaging/presentation/providers/socket_provider.dart';

/// Notifier that manages the state of sending a message or starting a conversation.
///
/// The state ([bool]) represents whether a message is currently being sent
/// (`true` for loading, `false` otherwise).
///
/// Depends on [repositoryprovider], [conversationProvider], and [messageProvider].
class SendMessageNotifier extends StateNotifier<bool> {
  final Ref ref;

  SendMessageNotifier({required this.ref}) : super(false);

  /// Sends a message within an existing conversation or starts a new one.
  ///
  /// If [conversationId] is provided, it uses [SendMessageUsecase] to send the message.
  /// Otherwise, it uses [StartConversationUsecase] with [newParticipantId].
  ///
  /// Side effects:
  /// - Updates the local state to `true` during the operation.
  /// - Invalidates [conversationProvider] and [messageProvider] upon success to trigger UI updates.
  /// - Syncs with the [RemoteDataSource] via the repository.
  Future<Conversation?> sendMessage({
    String? body,
    String? conversationId,
    String? newParticipantId,
    String? embedId,
    String? embedType,
  }) async {
    state = true;
    if (conversationId != null) {
      final uCase = SendMessageUsecase(repo: ref.read(repositoryprovider));
      final message = await (uCase(conversationId, body, embedId, embedType));

      final socket = ref.read(socketProvider);
      socket.sendMessage(conversationId, {'messageId': message.messageId});

      ref.invalidate(conversationProvider);
      ref.invalidate(messagesNotifierProvider(conversationId));
      state = false;
      return null;
    } else {
      final uCase = StartConversationUsecase(
        repo: ref.read(repositoryprovider),
      );
      final trackId = embedType == 'track' ? embedId : null;
      final playlistId = embedType != 'track' ? embedId : null;
      final newConv = await uCase(
        newParticipantId!,
        body: body,
        trackId: trackId,
        playlistId: playlistId,
      );
      ref.invalidate(conversationProvider);
      ref.invalidate(messagesNotifierProvider(newConv.conversationId));
      state = false;
      return newConv;
    }
  }

  Future<Conversation> ensureConversation(String participantId) async {
    state = true;
    final newConv = await EnsureConversationUsecase(
      repo: ref.read(repositoryprovider),
    ).call(participantId);
    state = false;

    return newConv;
  }
}
