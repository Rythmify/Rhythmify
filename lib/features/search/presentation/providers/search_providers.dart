import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/search_repository_impl.dart';
import '../../data/datasources/search_remote_datasource.dart';
import '../../domain/entities/search_suggestion.dart';
import '../../domain/entities/search_results.dart';
import '../../domain/usecases/get_search_suggestions.dart';
import '../../domain/usecases/get_search_results.dart';
import '../../data/datasources/search_mock_datasource.dart'; // now has Impl
// now has Impl

// ── Dependency graph ──────────────────────────────────────────────────────────

const bool _useSearchMock = false;

final searchRemoteSourceProvider = Provider<SearchRemoteSource>(
  (_) => _useSearchMock ? SearchRemoteSourceMock() : SearchRemoteSourceImpl(),
);

/// Provides the repository, injecting the remote source.
final searchRepositoryProvider = Provider(
  (ref) =>
      SearchRepositoryImpl(remoteSource: ref.watch(searchRemoteSourceProvider)),
);

/// Provides the [GetSearchSuggestions] use case.
final getSearchSuggestionsProvider = Provider(
  (ref) => GetSearchSuggestions(ref.watch(searchRepositoryProvider)),
);

/// Provides the [GetSearchResults] use case.
final getSearchResultsProvider = Provider(
  (ref) => GetSearchResults(ref.watch(searchRepositoryProvider)),
);

// ── State notifiers ───────────────────────────────────────────────────────────

/// Holds the current text in the search bar.
class SearchQueryNotifier extends Notifier<String> {
  @override
  String build() => '';

  void update(String query) => state = query;
}

final searchQueryProvider = NotifierProvider<SearchQueryNotifier, String>(
  SearchQueryNotifier.new,
);

/// Tracks whether the user has submitted a search (i.e. pressed enter / search button).
/// When `true`, the results tabs are shown instead of suggestions.
class SearchSubmittedNotifier extends Notifier<bool> {
  @override
  bool build() => false;

  void submit() => state = true;
  void reset() => state = false;
}

final searchSubmittedProvider = NotifierProvider<SearchSubmittedNotifier, bool>(
  SearchSubmittedNotifier.new,
);

// ── Async providers ───────────────────────────────────────────────────────────

/// Debounces [searchQueryProvider] by 400ms to avoid firing a request on every keystroke.
final debouncedQueryProvider = StreamProvider.autoDispose<String>((ref) async* {
  final query = ref.watch(searchQueryProvider);
  await Future.delayed(const Duration(milliseconds: 400));
  yield query;
});

/// Fetches autocomplete suggestions for the debounced query.
/// Returns an empty list if the query is blank.
final searchSuggestionsProvider =
    FutureProvider.autoDispose<List<SearchSuggestion>>((ref) async {
      final query = ref.watch(debouncedQueryProvider).value ?? '';
      if (query.trim().isEmpty) return [];
      return ref.read(getSearchSuggestionsProvider).call(query);
    });

/// Fetches full search results for the current query.
/// Returns an empty [SearchResults] if the query is blank.
final searchResultsProvider = FutureProvider.autoDispose<SearchResults>((
  ref,
) async {
  final query = ref.watch(searchQueryProvider);
  if (query.trim().isEmpty) return const SearchResults(tracks: []);
  return ref.read(getSearchResultsProvider).call(query);
});
