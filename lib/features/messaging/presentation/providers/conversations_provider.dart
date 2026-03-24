import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rythmify/features/messaging/domain/entities/conversation.dart';
import 'package:rythmify/features/messaging/domain/usecases/get_conversations_usecase.dart';
import 'package:rythmify/features/messaging/presentation/providers/repository_provider.dart';

/// Provider for the list of active [Conversation]s for the current user.
///
/// This provider uses [GetConversationsUsecase] to retrieve all chat summaries
/// from the [MessagingRepository].
///
/// Depends on [repositoryprovider].
final conversationProvider = FutureProvider<List<Conversation>>((ref) async {
  final uCase = GetConversationsUsecase(repo: ref.read(repositoryprovider));
  final convs = await uCase();
  return convs;
});
