/// A single autocomplete suggestion returned while the user is typing a search query.
class SearchSuggestion {
  /// Unique identifier for this suggestion.
  final String id;

  /// The display text shown in the suggestions list.
  final String text;

  /// The content type this suggestion refers to (e.g. `'track'`, `'user'`, `'playlist'`).
  final String type;
  final String? avatarUrl;

  const SearchSuggestion({
    required this.id,
    required this.text,
    required this.type,
    this.avatarUrl,
  });
}
