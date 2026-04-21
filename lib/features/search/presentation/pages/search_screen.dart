import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/search_providers.dart';
import '../widgets/search_bar.dart';
import '../widgets/search_suggestions_list.dart';
import '../widgets/search_results_tab.dart';
import '../widgets/vibes_grid.dart';
import '../pages/vibes_genre_page.dart';
import '../providers/vibes_providers.dart';

/// The main search screen. Renders one of three states depending on user input:
/// - **Idle** (empty query): shows the vibes grid.
/// - **Typing** (query not submitted): shows the autocomplete suggestions list.
/// - **Submitted**: shows the tabbed search results page.
///
/// Also listens to [searchQueryProvider] to auto-reset the submitted state
/// when the user clears the search bar.
class SearchScreen extends ConsumerWidget {
  const SearchScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final query = ref.watch(searchQueryProvider);
    final submitted = ref.watch(searchSubmittedProvider);

    // Reset submitted state whenever the query is cleared.
    ref.listen(searchQueryProvider, (_, next) {
      if (next.trim().isEmpty) {
        ref.read(searchSubmittedProvider.notifier).reset();
      }
    });

    return Scaffold(
      key: const Key('search_screen'),
      appBar: AppBar(title: const Text('Search'), centerTitle: false),
      body: Column(
        children: [
          const SearchBarWidget(),

          if (submitted)
            const Expanded(
              key: Key('search_results_tabs'),
              child: SearchResultsTabs(),
            )
          else if (query.trim().isNotEmpty)
            const Expanded(
              key: Key('search_suggestions_list'),
              child: SearchSuggestionsList(),
            )
          else
            // Idle state: load and display the vibes grid.
            Expanded(
              key: const Key('vibes_section'),
              child: ref
                  .watch(vibesProvider)
                  .when(
                    loading: () => const Center(
                      key: Key('vibes_loading'),
                      child: CircularProgressIndicator(),
                    ),
                    error: (e, _) => Center(
                      key: Key('vibes_error'),
                      child: Text('Error: $e'),
                    ),
                    data: (vibes) => ListView(
                      key: const Key('vibes_list'),
                      padding: const EdgeInsets.fromLTRB(8, 0, 8, 100),
                      children: [
                        const Padding(
                          padding: EdgeInsets.fromLTRB(15, 10, 0, 16),
                          child: Text(
                            'Vibes',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                        VibesGrid(
                          key: const Key('vibes_grid'),
                          vibes: vibes,
                          // Navigates to the genre page for the tapped vibe.
                          onVibeTap: (vibe) => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => GenrePage(
                                genreId: vibe.id,
                                genreName: vibe.title,
                                coverImage: vibe
                                    .imagePath, // empty string until endpoint adds it
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
            ),
        ],
      ),
    );
  }
}
