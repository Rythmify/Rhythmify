import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rythmify/features/messaging/presentation/widgets/compose_button.dart';
import 'package:rythmify/features/messaging/presentation/widgets/empty_inbox.dart';
import 'package:rythmify/features/messaging/presentation/widgets/inbox_conversations.dart';
import 'package:rythmify/features/messaging/presentation/providers/conversations_provider.dart';

class InboxScreen extends ConsumerWidget {
  const InboxScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final convprovider=ref.watch(conversationProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Inbox'),
        centerTitle: false,
      ),
      body: convprovider.when(
      data: (conversations){
        return conversations.isEmpty?
        const EmptyInbox()
        :InboxConversations(conversations: conversations);
      },
      error: (error, stackTrace) => Center(
        child: Text(error.toString())
        ),
      loading: () => const Center(
        child: CircularProgressIndicator(),)), 
        floatingActionButton: ComposeButton()
    );
  }
}