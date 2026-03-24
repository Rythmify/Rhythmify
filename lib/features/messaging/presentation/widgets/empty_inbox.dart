import 'package:flutter/material.dart';
import 'package:rythmify/core/theme/messaging_themes.dart';

class EmptyInbox extends StatelessWidget {
  const EmptyInbox({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Message other fans and artists, and share your favourite tracks, playlists and uploads',
              key: const Key('messaging_empty_inbox_message_text'),
              textAlign: TextAlign.center,
              style: MessagingThemes.inboxEmptyMsg,
            ),
            SizedBox(height: 12),
            Text(
              'Start a conversation by tapping the compose icon below.',
              key: const Key('messaging_empty_inbox_instruction_text'),
              textAlign: TextAlign.center,
              style: MessagingThemes.inboxEmptysubMsg,
            ),
          ],
        ),
      ),
    );
  }
}
