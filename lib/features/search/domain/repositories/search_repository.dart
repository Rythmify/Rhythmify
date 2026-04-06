import '../entities/search_suggestion.dart';
import '../entities/search_results.dart';

abstract class SearchRepository {
  Future<List<SearchSuggestion>> getSuggestions(String query);
  Future<SearchResults> getSearchResults(String query);
}
