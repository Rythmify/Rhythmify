/// Mock store — holds submitted track data in memory
/// Replace with real repository when backend is ready
///
/// HOW TO USE:
///   After save is pressed, data is stored here.
///   Any screen can read UploadMockStore.submissions
///   to see what was submitted.
///
///   Print it to console:
///   print(UploadMockStore.submissions);

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
    // Print to console so you can see it during testing
    print('=== NEW TRACK SUBMITTED ===');
    print(submission);
    print('Total submissions: ${submissions.length}');
  }

  static void clear() => submissions.clear();
}