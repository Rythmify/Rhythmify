import '../../domain/entities/search_suggestion.dart';
import '../../domain/repositories/search_repository.dart';
import '../datasources/search_remote_datasource.dart';

class SearchRepositoryImpl implements SearchRepository {
  final SearchRemoteSource remoteSource;
  SearchRepositoryImpl({required this.remoteSource});

  @override
  Future<List<SearchSuggestion>> getSuggestions(String query) =>
      remoteSource.getSuggestions(query);
}
