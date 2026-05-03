import '../entities/search_suggestion.dart';
import '../entities/search_results.dart';

/// Domain contract for the search feature.
/// Defines the operations the presentation layer can request — implementation lives in the data layer.
abstract class SearchRepository {
  /// Returns autocomplete suggestions matching [query].
  Future<List<SearchSuggestion>> getSuggestions(String query);

  /// Returns full search results across all content types for [query].
  Future<SearchResults> getSearchResults(String query);

  Future<SearchResults> getSearchResultsTyped(String query, String type);
}
