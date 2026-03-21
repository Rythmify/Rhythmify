import 'package:flutter/material.dart';
import 'package:rythmify/features/messaging/presentation/widgets/avatar.dart';

class MessageBubble extends StatelessWidget{
    final String senderId;
    final String? body;
    final String myId;
    final String? embedId;
    final String? embedType;
    final DateTime sentAt;
    final String? userAvatar;

    const MessageBubble({
        super.key,
        required this.myId,
        this.body,
        this.embedId,
        this.embedType,
        required this.senderId,
        required this.sentAt,
        this.userAvatar
    });

    bool get isMe=>(senderId==myId);
String fixTime(DateTime date)
  {
    final duration=DateTime.now().difference(date);

    if(duration.inDays>=365)
    {
      return '${duration.inDays~/365} years ago';
    }
    else if(duration.inDays>=30)
    {
      return '${duration.inDays~/30} months ago';
    }
    else if(duration.inDays>=7)
    {
      return '${duration.inDays~/7} weaks ago';
    }
    else if(duration.inDays>=1)
    {
      return '${duration.inDays~/1} days ago';
    }
    else if(duration.inHours>=1)
    {
      return '${duration.inHours~/1} hours ago';
    }
    else if(duration.inMinutes>=1)
    {
      return '${duration.inMinutes~/1} mminutes ago';
    }
    else 
    {
      return '${duration.inSeconds} seconds ago';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
       padding:EdgeInsets.only(bottom: 22),
       child: Column(
        crossAxisAlignment: isMe?CrossAxisAlignment.end:CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: isMe?MainAxisAlignment.end:MainAxisAlignment.start,
            children: [
            if(!isMe)...[
              Avatar(
                img:userAvatar,
                radius: 18,
              ),
              const SizedBox(width: 10)
            ],
            Flexible(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 280),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 14
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2F2F31),
                    borderRadius: BorderRadius.circular(18)
                  ),
                  child: Text(
                    body??'',
                    key: Key('messaging_message_bubble_item_${senderId}_${sentAt.millisecondsSinceEpoch}_body_text'),
                    style:const TextStyle(
                      color: Colors.white,
                      fontSize: 18
                    )
                  ),
                ),
                )
            )
          ],
          ),
          Padding(padding: EdgeInsets.only(
            left:isMe?0:46,
            right:isMe?8:0,
            top:6
          ),
          child: Text(
            fixTime(sentAt),
            key: Key('messaging_message_bubble_item_${senderId}_${sentAt.millisecondsSinceEpoch}_time_text'),
            style: const TextStyle(
              color:Colors.white70,
              fontSize: 12
             ),
          ),
          )
        ],
       ),
       
    );  
  }
}