import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/search_providers.dart';
import '../widgets/search_bar.dart';
import '../widgets/search_suggestions_list.dart';
import '../widgets/search_results_tab.dart';
import '../widgets/vibes_grid.dart';
import '../pages/vibes_genre_page.dart';

class SearchScreen extends ConsumerWidget {
  const SearchScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final query = ref.watch(searchQueryProvider);
    final submitted = ref.watch(searchSubmittedProvider); // ← new

    // reset submitted when query is cleared
    ref.listen(searchQueryProvider, (_, next) {
      if (next.trim().isEmpty) {
        ref.read(searchSubmittedProvider.notifier).reset();
      }
    });

    return Scaffold(
      appBar: AppBar(title: const Text('Search'), centerTitle: false),
      body: Column(
        children: [
          const SearchBarWidget(),

          if (submitted)
            const Expanded(child: SearchResultsTabs()) // ← new
          else if (query.trim().isNotEmpty)
            const Expanded(child: SearchSuggestionsList())
          else
            Expanded(
              child: ListView(
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
                    vibes: vibes,
                    onVibeTap: (vibe) => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => GenrePage(genre: vibe.id),
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
