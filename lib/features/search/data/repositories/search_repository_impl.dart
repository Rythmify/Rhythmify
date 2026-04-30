import '../../domain/entities/search_suggestion.dart';
import '../../domain/entities/search_results.dart';
import '../../domain/repositories/search_repository.dart';
import '../datasources/search_remote_datasource.dart';

/// Concrete implementation of [SearchRepository].
/// Delegates all calls directly to [SearchRemoteSource] — no local caching or transformation needed.
class SearchRepositoryImpl implements SearchRepository {
  final SearchRemoteSource remoteSource;

  SearchRepositoryImpl({required this.remoteSource});

  @override
  Future<List<SearchSuggestion>> getSuggestions(String query) =>
      remoteSource.getSuggestions(query);

  @override
  Future<SearchResults> getSearchResults(String query) =>
      remoteSource.getSearchResults(query);

  @override
  Future<SearchResults> getSearchResultsTyped(String query, String type) =>
      remoteSource.getSearchResultsTyped(query, type);
}
