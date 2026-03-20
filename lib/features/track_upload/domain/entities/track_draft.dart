enum UploadStatus { draft, uploading, success, error }

class TrackDraft {

  //added recently
  final String? audioFileName; 
  // Known at creation
  final String artistId;
  final String localAudioPath;
  final Duration duration;

  // Filled on form screen
  final String? title;
  final String? artist;
  final String? genre;           // ← NEW: single genre selection
  final String? localArtworkPath;
  final String? description;
  final String? caption;         // ← NEW: short optional caption

  // Has defaults
  final List<String> tags;       // multiple tag selections
  final bool isPublic;
  final UploadStatus status;
  final double uploadProgress;

  const TrackDraft({
    this.audioFileName,
    required this.artistId,
    required this.localAudioPath,
    required this.duration,
    this.title,
    this.artist,
    this.genre,
    this.localArtworkPath,
    this.description,
    this.caption,
    this.tags = const [],
    this.isPublic = true,
    this.status = UploadStatus.draft,
    this.uploadProgress = 0.0,
  });

  TrackDraft copyWith({
    //added recently
    String? audioFileName,

    String? artistId,
    String? localAudioPath,
    Duration? duration,
    String? title,
    String? artist,
    String? genre,
    String? localArtworkPath,
    String? description,
    String? caption,
    List<String>? tags,
    bool? isPublic,
    UploadStatus? status,
    double? uploadProgress,
    bool clearArtwork = false,
    bool clearDescription = false,
    bool clearCaption = false,
  }) {
    return TrackDraft(
      //added recently
      audioFileName:    audioFileName  ?? this.audioFileName,
      
      artistId:         artistId       ?? this.artistId,
      localAudioPath:   localAudioPath ?? this.localAudioPath,
      duration:         duration       ?? this.duration,
      title:            title          ?? this.title,
      artist:           artist         ?? this.artist,
      genre:            genre          ?? this.genre,
      localArtworkPath: clearArtwork
                          ? null
                          : localArtworkPath ?? this.localArtworkPath,
      description:      clearDescription
                          ? null
                          : description ?? this.description,
      caption:          clearCaption
                          ? null
                          : caption ?? this.caption,
      tags:             tags           ?? this.tags,
      isPublic:         isPublic       ?? this.isPublic,
      status:           status         ?? this.status,
      uploadProgress:   uploadProgress ?? this.uploadProgress,
    );
  }

  @override
  String toString() => 'TrackDraft('
      'title: $title, '
      'artist: $artist, '
      'genre: $genre, '
      'status: $status, '
      'progress: $uploadProgress'
      ')';
}