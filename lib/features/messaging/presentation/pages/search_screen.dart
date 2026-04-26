import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rythmify/core/theme/messaging_themes.dart';
import 'package:rythmify/features/messaging/domain/entities/potential_conversation.dart';
import 'package:rythmify/features/messaging/presentation/providers/get_followings_provider.dart';
import 'package:rythmify/features/messaging/presentation/providers/get_searched_users_provider.dart';
import 'package:rythmify/features/messaging/presentation/providers/search_query_provider.dart';
import 'package:rythmify/features/messaging/presentation/widgets/search_body.dart';
import 'package:rythmify/features/messaging/presentation/widgets/searchbar_widget.dart';

/// A screen for searching users to start a new conversation.
///
/// It displays a search bar and shows following users by default,
/// allowing the user to search for other artists and fans to message.
class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  late final TextEditingController controller;
  @override
  void initState() {
    super.initState();
    controller = TextEditingController();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  List<PotentialConversation> _searchBody({
    List<PotentialConversation> followings = const [],
    List<PotentialConversation> searchedUsers = const [],
    String query = '',
  }) {
    final filteredFollowings = followings
        .where(
          (s) => s.participantName.toLowerCase().contains(query.toLowerCase()),
        )
        .toList();

    final followingsIds = followings.map((s) => s.participantId).toSet();
    final filteredUsers = searchedUsers
        .where((s) => !followingsIds.contains(s.participantId))
        .toList();
    // .where(
    //   (s) =>
    //       s.participantName.toLowerCase().startsWith(query.toLowerCase()) &&
    //       !followingsIds.contains(s.participantId),
    // )
    // .toList();

    return [...filteredFollowings, ...filteredUsers];
  }

  @override
  Widget build(BuildContext context) {
    final query = ref.watch(queryProvider);
    final followings = ref.watch(getFollowingsProvider);
    final searchedUsers = ref.watch(getSearchedUsersProvider(query));
    final followingList = followings.whenOrNull(data: (d) => d) ?? [];

    final List<PotentialConversation> searched = _searchBody(
      followings: followingList,
      searchedUsers: searchedUsers.whenOrNull(data: (d) => d) ?? [],
      query: query,
    );

    return Scaffold(
      appBar: AppBar(title: const Text('New Message'), centerTitle: false),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: SearchBarWidget(
              key: const Key('search_screen_new_message_search_bar'),
              controller: controller,
              onChanged: (value) {
                ref.read(queryProvider.notifier).state = value.trim();
              },
            ),
          ),
          Expanded(
            child: query.isEmpty
                ? followings.when(
                    data: (_) => followingList.isEmpty
                        ? Text(
                            'Start typing to sind artists and fans on SoundCloud',
                            key: const Key('messaging_empty_Search_users_text'),
                            textAlign: TextAlign.center,
                            style: MessagingThemes
                                .inboxEmptyMsg, //same theme as the emptyInbox msg
                          )
                        : SearchBody(users: followingList),
                    error: (e, _) => Center(child: Text(e.toString())),
                    loading: () =>
                        const Center(child: CircularProgressIndicator()),
                  )
                : searched.isEmpty && searchedUsers.isLoading
                ? const Center(child: CircularProgressIndicator())
                : searched.isEmpty
                ? const SizedBox.shrink()
                : SearchBody(users: searched),
          ),
        ],
      ),
    );
  }
}
