/// Mock Store: UploadMockStore
///
/// Temporary in-memory storage used for testing track uploads.
///
/// Responsibilities:
/// - Store mock track submissions locally
/// - Allow testing without backend integration
///
/// Notes:
/// - Used only for debugging and development
/// - Should not be used in production
class MockTrackSubmission {
  final String title;
  final String artist;
  final String? genre;
  final List<String> tags;
  final String? description;
  final String? caption;
  final bool isPublic;
  final String localAudioPath;
  final String? localArtworkPath;
  final Duration duration;
  final DateTime submittedAt;

  const MockTrackSubmission({
    required this.title,
    required this.artist,
    this.genre,
    required this.tags,
    this.description,
    this.caption,
    required this.isPublic,
    required this.localAudioPath,
    this.localArtworkPath,
    required this.duration,
    required this.submittedAt,
  });

  @override
  String toString() {
    return '''
MockTrackSubmission:
  title:         $title
  artist:        $artist
  genre:         $genre
  tags:          $tags
  description:   $description
  caption:       $caption
  isPublic:      $isPublic
  audioPath:     $localAudioPath
  artworkPath:   $localArtworkPath
  duration:      ${duration.inSeconds}s
  submittedAt:   $submittedAt
''';
  }
}

class UploadMockStore {
  UploadMockStore._();

  // All submitted tracks stored in memory
  static final List<MockTrackSubmission> submissions = [];

  static void add(MockTrackSubmission submission) {
    submissions.add(submission);
  }

  static void clear() => submissions.clear();
}
