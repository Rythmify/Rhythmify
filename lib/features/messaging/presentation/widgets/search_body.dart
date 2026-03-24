import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rythmify/features/messaging/domain/entities/conversation.dart';
import 'package:rythmify/features/messaging/domain/entities/potential_conversation.dart';
import 'package:rythmify/features/messaging/presentation/pages/chat_screen.dart';
import 'package:rythmify/features/messaging/presentation/providers/conversations_provider.dart';
import 'package:rythmify/features/messaging/presentation/widgets/search_conversation_tile.dart';

class SearchBody extends ConsumerWidget {
  final List<PotentialConversation> users;
  const SearchBody({super.key, required this.users});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final conversationsMade =
        ref.watch(conversationProvider).whenOrNull(data: (d) => d) ?? [];

    return ListView.builder(
      itemCount: users.length,
      itemBuilder: (context, index) {
        final user = users[index];
        final previousConv = conversationsMade.cast<Conversation?>().firstWhere(
          (c) => c?.participantId == user.participantId,
          orElse: () => null,
        );
        return SearchConversationTile(
          participantName: user.participantName,
          participantfollowers: user.followersCount ?? 0,
          participantAvatar: user.avatar,
          participantCountry: user.location,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ChatScreen(
                  conv: previousConv,
                  newParticipantId: user.participantId,
                  newParticipantName: user.participantName,
                ),
              ),
            );
          },
        );
      },
    );
  }
}
