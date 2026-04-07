import '../entities/search_suggestion.dart';
import '../repositories/search_repository.dart';

class GetSearchSuggestions {
  final SearchRepository repository;
  GetSearchSuggestions(this.repository);

  Future<List<SearchSuggestion>> call(String query) =>
      repository.getSuggestions(query);
}
