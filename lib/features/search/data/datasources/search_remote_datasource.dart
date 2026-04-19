import '../../domain/entities/search_suggestion.dart';
import '../../domain/entities/search_results.dart';

/// Contract for the search remote data source.
abstract class SearchRemoteSource {
  /// Returns autocomplete suggestions matching [query].
  Future<List<SearchSuggestion>> getSuggestions(String query);

  /// Returns full search results across all content types for [query].
  Future<SearchResults> getSearchResults(String query);
}

/// Real HTTP implementation of [SearchRemoteSource].

class SearchRemoteSourceImpl implements SearchRemoteSource {
  @override
  Future<List<SearchSuggestion>> getSuggestions(String query) async {
    throw UnimplementedError('getSuggestions not yet implemented');
  }

  @override
  Future<SearchResults> getSearchResults(String query) async {
    throw UnimplementedError('getSearchResults not yet implemented');
  }
}
