class SharedEmbed {
  final String embedId;
  final String embedType;
  final String embedName;
  final String? artistName;
  final String? thumbnailUrl;

  SharedEmbed({
    required this.embedId,
    required this.embedType,
    required this.embedName,
    this.artistName,
    this.thumbnailUrl
  });
}