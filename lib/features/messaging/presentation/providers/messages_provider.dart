import 'package:rythmify/features/messaging/domain/entities/message.dart';
import 'package:rythmify/features/messaging/domain/usecases/get_messages_usecase.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rythmify/features/messaging/presentation/providers/repository_provider.dart';

/// Provider for fetching the list of [Message]s in a specific conversation.
///
/// This provider uses the [GetMessagesUsecase] to retrieve historical messages
/// from the [MessagingRepository].
///
/// Depends on [repositoryprovider].
final messageProvider = FutureProvider.family<List<Message>, String>((
  ref,
  conversationId,
) async {
  final uCase = GetMessagesUsecase(repo: ref.read(repositoryprovider));
  final msg = await uCase(conversationId);
  return msg;
});
