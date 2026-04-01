import '../entities/search_suggestion.dart';

abstract class SearchRepository {
  Future<List<SearchSuggestion>> getSuggestions(String query);
}
