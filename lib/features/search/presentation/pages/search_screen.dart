import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/search_providers.dart';
import '../widgets/search_bar.dart';
import '../widgets/search_suggestions_list.dart';

class SearchScreen extends ConsumerWidget {
  const SearchScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final query = ref.watch(searchQueryProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Search'), centerTitle: false),
      body: Column(
        children: [
          const SearchBarWidget(),
          if (query.trim().isNotEmpty)
            const Expanded(child: SearchSuggestionsList()),
        ],
      ),
    );
  }
}
