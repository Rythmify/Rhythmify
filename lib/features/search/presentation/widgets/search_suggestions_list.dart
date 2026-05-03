import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/search_providers.dart';
import 'package:go_router/go_router.dart';

/// Displays debounced autocomplete suggestions while the user is typing.
/// Shown between the search bar and the vibes grid, before the query is submitted.
///
/// Tapping a suggestion fills the search bar with that text and immediately
/// submits it, transitioning the screen to the results view.
/// Uses [skipLoadingOnReload] to avoid a flicker on each keystroke.
class SearchSuggestionsList extends ConsumerWidget {
  const SearchSuggestionsList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(searchSuggestionsProvider);

    return async.when(
      skipLoadingOnReload: true,
      loading: () => const Center(
        key: Key('suggestions_loading'),
        child: CircularProgressIndicator(),
      ),
      error: (e, _) =>
          Center(key: const Key('suggestions_error'), child: Text('Error: $e')),
      data: (suggestions) {
        if (suggestions.isEmpty) {
          return const Center(
            key: Key('suggestions_empty'),
            child: Text('No results found'),
          );
        }
        return ListView.builder(
          key: const Key('suggestions_list'),
          itemCount: suggestions.length,
          itemBuilder: (_, i) {
            final suggestion = suggestions[i];
            final isUser = suggestion.type == 'user';

            return ListTile(
              key: Key('suggestion_tile_$i'),
              leading: isUser
                  ? CircleAvatar(
                      radius: 20,
                      backgroundImage: suggestion.avatarUrl != null
                          ? NetworkImage(suggestion.avatarUrl!)
                          : null,
                      child: suggestion.avatarUrl == null
                          ? const Icon(Icons.person, size: 20)
                          : null,
                    )
                  : null,
              title: Text(suggestion.text),
              trailing: const Icon(Icons.north_west, size: 16),
              onTap: () {
                if (suggestion.type == 'user') {
                  context.push('/home/profile/${suggestion.id}');
                } else {
                  ref
                      .read(searchQueryProvider.notifier)
                      .update(suggestion.text);
                  ref.read(searchSubmittedProvider.notifier).submit();
                }
              },
            );
          },
        );
      },
    );
  }
}
