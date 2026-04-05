import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/search_providers.dart';

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
            return ListTile(
              key: Key('suggestion_tile_$i'),
              title: Text(suggestions[i].text),
              trailing: const Icon(Icons.north_west, size: 16),
              onTap: () {
                ref
                    .read(searchQueryProvider.notifier)
                    .update(suggestions[i].text);
                ref.read(searchSubmittedProvider.notifier).submit();
              },
            );
          },
        );
      },
    );
  }
}
