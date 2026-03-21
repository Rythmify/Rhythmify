import 'package:flutter/material.dart';
import 'package:rythmify/core/theme/messaging_themes.dart';
import 'package:rythmify/features/messaging/presentation/widgets/avatar.dart';

class SearchConversationTile extends StatelessWidget{
  final String participantName;
  final int participantfollowers;
  final String? participantAvatar;
  final String? participantCountry;
  final VoidCallback? onTap;

  const SearchConversationTile({
    super.key,
    this.participantAvatar,
    required this.participantName,
    required this.participantfollowers,
    this.participantCountry,
    this.onTap
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      key: Key('messaging_search_conversation_item_${participantName}_list_tile'),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16,vertical: 8),
      tileColor: Colors.transparent,
      leading: Avatar(
        img: participantAvatar,
        radius: 22,
      ),
      title: Text(
        participantName,
        key: Key('messaging_search_conversation_item_${participantName}_name_text'),
        style: MessagingThemes.searchPName,
        ),
      subtitle: Column(
        children: [
          if(participantCountry!=null) Text(
            participantCountry!,
            key: Key('messaging_search_conversation_item_${participantName}_country_text'),
            style: MessagingThemes.searchPCountry,
          ),
          Row(
            children: [
              Icon(Icons.person,size: 14,color: Color(0xFFB3B3B3),),
              SizedBox(width: 4),
              Text(
                '$participantfollowers Followers',
                key: Key('messaging_search_conversation_item_${participantName}_followers_text'),
                style: MessagingThemes.searchPCountry,
                )
            ],
          )
        ],
      ),
      //
    );
  }
}