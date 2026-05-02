/// Domain Entity: TrackDraft
///
/// Represents a temporary track being prepared for upload.
///
/// This entity holds all metadata and file references required
/// before sending the track to the backend.
enum UploadStatus { draft, uploading, success, error }

class TrackDraft {
  final String? trackId; // null for new uploads, present for updates
  final String? remoteArtworkUrl; // track's existing cover image URL
  //added recently
  final String? audioFileName;
  // Known at creation
  final String artistId;
  final String localAudioPath;
  final Duration duration;

  // Filled on form screen
  final String? title;
  final String? artist;
  final String? genre; // ← NEW: single genre selection
  final String? localArtworkPath;
  final String? description;
  final String? caption; // ← NEW: short optional caption

  // Has defaults
  final List<String> tags; // multiple tag selections
  final bool isPublic;
  final String geoRestrictionType;
  final List<String> geoRegions; // list of country codes
  final UploadStatus status;
  final double uploadProgress;

  final UploadStatus audioStatus; // tracks the audio file upload
  final double audioUploadProgress;

  // the purple track info button
  // Add this inside TrackDraft class
  int get checklistCount {
    int count = 0;
    if (title != null && title!.trim().isNotEmpty) count++;
    if (localArtworkPath != null || remoteArtworkUrl != null) count++;
    if (genre != null && genre!.trim().isNotEmpty) count++;
    if (description != null && description!.trim().isNotEmpty) count++;
    return count; // 0 to 4
  }

  const TrackDraft({
    this.trackId,
    this.remoteArtworkUrl,
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
    this.geoRestrictionType = 'worldwide',
    this.geoRegions = const [],
    this.status = UploadStatus.draft,
    this.uploadProgress = 0.0,
    this.audioStatus = UploadStatus.uploading, // ← starts uploading
    this.audioUploadProgress = 0.0,
  });

  TrackDraft copyWith({
    String? trackId,
    String? remoteArtworkUrl,
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
    String? geoRestrictionType,
    List<String>? geoRegions,
    UploadStatus? status,
    double? uploadProgress,
    UploadStatus? audioStatus,
    double? audioUploadProgress,
    bool clearArtwork = false,
    bool clearDescription = false,
    bool clearCaption = false,
  }) {
    return TrackDraft(
      trackId: trackId ?? this.trackId,
      remoteArtworkUrl: remoteArtworkUrl ?? this.remoteArtworkUrl,
      audioFileName: audioFileName ?? this.audioFileName,
      artistId: artistId ?? this.artistId,
      localAudioPath: localAudioPath ?? this.localAudioPath,
      duration: duration ?? this.duration,
      title: title ?? this.title,
      artist: artist ?? this.artist,
      genre: genre ?? this.genre,
      localArtworkPath: clearArtwork
          ? null
          : localArtworkPath ?? this.localArtworkPath,
      description: clearDescription ? null : description ?? this.description,
      caption: clearCaption ? null : caption ?? this.caption,
      tags: tags ?? this.tags,
      isPublic: isPublic ?? this.isPublic,
      geoRestrictionType: geoRestrictionType ?? this.geoRestrictionType,
      geoRegions: geoRegions ?? this.geoRegions,
      status: status ?? this.status,
      uploadProgress: uploadProgress ?? this.uploadProgress,
      audioStatus: audioStatus ?? this.audioStatus,
      audioUploadProgress: audioUploadProgress ?? this.audioUploadProgress,
    );
  }

  @override
  String toString() =>
      'TrackDraft(title: $title, artist: $artist, genre: $genre, status: $status, progress: $uploadProgress)';
}
