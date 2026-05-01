import '../entities/search_results.dart';
import '../repositories/search_repository.dart';

/// Use case that fetches search results

class GetSearchResults {
  final SearchRepository repository;
  GetSearchResults(this.repository);

  Future<SearchResults> call(String query) =>
      repository.getSearchResults(query);

  Future<SearchResults> callTyped(String query, String type) =>
      repository.getSearchResultsTyped(query, type);
}
