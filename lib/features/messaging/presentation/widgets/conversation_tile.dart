import 'package:flutter/material.dart';
import 'package:rythmify/features/messaging/presentation/widgets/avatar.dart';

class ConversationTile extends StatelessWidget {
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
    this.onTap,
  });

  String fixTime(DateTime date) {
    final duration = DateTime.now().difference(date);

    if (duration.inDays >= 365) {
      return '${duration.inDays ~/ 365}y';
    } else if (duration.inDays >= 30) {
      return '${duration.inDays ~/ 30}mo';
    } else if (duration.inDays >= 7) {
      return '${duration.inDays ~/ 7}w';
    } else if (duration.inDays >= 1) {
      return '${duration.inDays ~/ 1}d';
    } else if (duration.inHours >= 1) {
      return '${duration.inHours ~/ 1}h';
    } else if (duration.inMinutes >= 1) {
      return '${duration.inMinutes ~/ 1}m';
    } else {
      return '${duration.inSeconds}s';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(
        splashFactory: InkRipple.splashFactory,
        splashColor: const Color(0xFF2F2F2F),
        highlightColor:Colors.transparent,
        colorScheme: Theme.of(context).colorScheme.copyWith(
          primary: Colors.white, // this stops the orange from bleeding in
        ),
      ),
      child:ListTile(
      key: Key('messaging_conversation_item_${participantName}_list_tile'),
      onTap: onTap,
      tileColor: unreadCount == 0
          ? Colors.transparent
          : const Color(0xFF2F2F2F),
      leading: Avatar(img: participantAvatar, radius: 22),
      title: Text(
        participantName,
        key: Key('messaging_conversation_item_${participantName}_name_text'),
      ),
      subtitle: Row(
        children: [
          Expanded(
            child: Text(
              lastMessagePreview,
              key: Key(
                'messaging_conversation_item_${participantName}_preview_text',
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Text('. '),
          Text(
            fixTime(lastMessageDate),
            key: Key(
              'messaging_conversation_item_${participantName}_time_text',
            ),
          ),
        ],
      ),
    ));
  }
}
