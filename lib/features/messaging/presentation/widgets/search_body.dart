import 'package:flutter/material.dart';
import 'package:rythmify/features/messaging/domain/entities/potential_conversation.dart';
import 'package:rythmify/features/messaging/presentation/widgets/search_conversation_tile.dart';

class SearchBody extends StatelessWidget {
  final List<PotentialConversation> users;
  const SearchBody({
    super.key,
    required this.users
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: users.length,
      itemBuilder: (context, index) {
        final user=users[index];
        return SearchConversationTile(participantName: user.participantName,
        participantfollowers: user.followersCount??0,
        participantAvatar: user.avatar,
        participantCountry:user.location??'',
        onTap: (){},
        );
      },
    );
  }
}