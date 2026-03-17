import 'package:flutter/material.dart';
import 'package:rythmify/features/messaging/presentation/widgets/avatar.dart';

class ConversationTile extends StatelessWidget{
  final String? participantAvatar;
  final String participantName;
  final String lastMessagePreview;
  final DateTime lastMessageDate;
  final int unreadCount;
  final VoidCallback? onTap;


  const ConversationTile({
    super.key,
    this.participantAvatar,
    required this.participantName,
    required this.lastMessagePreview,
    required this.lastMessageDate,
    required this.unreadCount,
    this.onTap
  });

  String fixTime(DateTime date)
  {
    final duration=DateTime.now().difference(date);

    if(duration.inDays>365)
    {
      return '${duration.inDays~/365}y';
    }
    else if(duration.inDays>30)
    {
      return '${duration.inDays~/30}mo';
    }
    else if(duration.inDays>7)
    {
      return '${duration.inDays~/7}w';
    }
    else if(duration.inHours>24)
    {
      return '${duration.inHours~/24}d';
    }
    else if(duration.inMinutes>60)
    {
      return '${duration.inMinutes~/60}h';
    }
    else if(duration.inSeconds>60)
    {
      return '${duration.inSeconds~/60}m';
    }
    else 
    {
      return '${duration.inSeconds}s';
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      tileColor:unreadCount==0?Colors.transparent:const Color(0xFF2F2F2F),
      leading: Avatar(
        img: participantAvatar,
        radius: 22,
      ),
      title: Text(participantName),
      subtitle: Row(
        children: [
          Expanded(
            child: Text(lastMessagePreview,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    ),
          ),
          Text('. '),
          Text(fixTime(lastMessageDate))
        ],
      ),
    );
  }
}