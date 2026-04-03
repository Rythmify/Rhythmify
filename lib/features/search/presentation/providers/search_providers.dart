import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/search_repository_impl.dart';
import '../../data/datasources/search_remote_datasource.dart';
import '../../domain/entities/search_suggestion.dart';
import '../../domain/entities/search_results.dart';
import '../../domain/usecases/get_search_suggestions.dart';
import '../../domain/usecases/get_search_results.dart';

final searchRemoteSourceProvider = Provider<SearchRemoteSource>(
  (_) => SearchRemoteSourceMock(),
);

final searchRepositoryProvider = Provider(
  (ref) =>
      SearchRepositoryImpl(remoteSource: ref.watch(searchRemoteSourceProvider)),
);

final getSearchSuggestionsProvider = Provider(
  (ref) => GetSearchSuggestions(ref.watch(searchRepositoryProvider)),
);

final getSearchResultsProvider = Provider(
  (ref) => GetSearchResults(ref.watch(searchRepositoryProvider)),
);

class SearchQueryNotifier extends Notifier<String> {
  @override
  String build() => '';

  void update(String query) => state = query;
}

final searchQueryProvider = NotifierProvider<SearchQueryNotifier, String>(
  SearchQueryNotifier.new,
);

class SearchSubmittedNotifier extends Notifier<bool> {
  @override
  bool build() => false;

  void submit() => state = true;
  void reset() => state = false;
}

final searchSubmittedProvider = NotifierProvider<SearchSubmittedNotifier, bool>(
  SearchSubmittedNotifier.new,
);

final debouncedQueryProvider = StreamProvider.autoDispose<String>((ref) async* {
  final query = ref.watch(searchQueryProvider);
  await Future.delayed(const Duration(milliseconds: 400));
  yield query;
});

final searchSuggestionsProvider =
    FutureProvider.autoDispose<List<SearchSuggestion>>((ref) async {
      final query = ref.watch(debouncedQueryProvider).value ?? '';
      if (query.trim().isEmpty) return [];
      return ref.read(getSearchSuggestionsProvider).call(query);
    });

final searchResultsProvider = FutureProvider.autoDispose<SearchResults>((
  ref,
) async {
  final query = ref.watch(searchQueryProvider);
  if (query.trim().isEmpty) return const SearchResults(tracks: []);
  return ref.read(getSearchResultsProvider).call(query);
});
