import '../../domain/entities/search_suggestion.dart';

abstract class SearchRemoteSource {
  Future<List<SearchSuggestion>> getSuggestions(String query);
}

class SearchRemoteSourceMock implements SearchRemoteSource {
  static const _mock = [
    SearchSuggestion(id: '1', text: 'Blinding Lights', type: 'track'),
    SearchSuggestion(id: '2', text: 'The Weeknd', type: 'user'),
    SearchSuggestion(id: '3', text: 'Chill Vibes', type: 'playlist'),
    SearchSuggestion(id: '4', text: 'Bad Guy', type: 'track'),
    SearchSuggestion(id: '5', text: 'Billie Eilish', type: 'user'),
    SearchSuggestion(id: '6', text: 'Lo-Fi Beats', type: 'playlist'),
    SearchSuggestion(id: '7', text: 'Shape of You', type: 'track'),
    SearchSuggestion(id: '8', text: 'Ed Sheeran', type: 'user'),
  ];

  @override
  Future<List<SearchSuggestion>> getSuggestions(String query) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final q = query.toLowerCase().trim();
    return _mock.where((s) => s.text.toLowerCase().startsWith(q)).toList();
  }
}
