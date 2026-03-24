import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:rythmify/features/messaging/presentation/widgets/compose_button.dart';
import 'package:rythmify/features/messaging/presentation/widgets/empty_inbox.dart';
import 'package:rythmify/features/messaging/presentation/widgets/inbox_conversations.dart';
import 'package:rythmify/features/messaging/presentation/providers/conversations_provider.dart';

class InboxScreen extends ConsumerWidget {
  const InboxScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final convprovider = ref.watch(conversationProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Inbox'), centerTitle: false),
      body: Padding(
        padding: const EdgeInsets.only(bottom: 130), // Space for player
        child: convprovider.when(
          data: (conversations) {
            return conversations.isEmpty
                ? const EmptyInbox()
                : InboxConversations(conversations: conversations);
          },
          error: (error, stackTrace) => Center(
            child: Text(error.toString(), key: const Key('inbox_error_text')),
          ),
          loading: () => const Center(child: CircularProgressIndicator()),
        ),
      ),
      floatingActionButton: Padding(
        padding: EdgeInsets.only(bottom: 130),
        child: ComposeButton(
          key: Key('inbox_compose_button'),
          onPressed: () {
            context.push('/home/inbox/search');
          },
        ),
      ),
    );
  }
}
