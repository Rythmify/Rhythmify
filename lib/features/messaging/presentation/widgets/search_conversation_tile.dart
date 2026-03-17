import 'package:flutter/material.dart';
import 'package:rythmify/core/theme/messaging_themes.dart';
import 'package:rythmify/features/messaging/presentation/widgets/avatar.dart';

class SearchConversationTile extends StatelessWidget{
  final String participantName;
  final int participantfollowers;
  final String? participantAvatar;
  final String? participantCountry;

  const SearchConversationTile({
    super.key,
    this.participantAvatar,
    required this.participantName,
    required this.participantfollowers,
    this.participantCountry
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      tileColor: Colors.transparent,
      leading: Avatar(
        img: participantAvatar,
        radius: 22,
      ),
      title: Text(
        participantName,
        style: MessagingThemes.searchPName,
        ),
      subtitle: Column(
        children: [
          if(participantCountry!=null) Text(participantCountry!,style: MessagingThemes.searchPCountry,),
          Row(
            children: [
              Icon(Icons.person,size: 14,color: Color(0xFFB3B3B3),),
              SizedBox(width: 4),
              Text(
                '$participantfollowers Followers',
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