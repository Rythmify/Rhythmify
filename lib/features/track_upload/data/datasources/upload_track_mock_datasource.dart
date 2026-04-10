import 'dart:io';
import '../models/upload_response_model.dart';
import 'upload_track_remote_datasource.dart';

/// Mock datasource for track upload — used when [_useMockUpload] is true in
/// [upload_track_provider.dart]. All methods return in-memory data without
/// making any network requests.
class UploadTrackMockDataSource extends UploadTrackRemoteDataSource {
  @override
  Future<List<String>> fetchTags() async {
    return const [
      'chill',
      'electronic',
      'pop',
      'hiphop',
      'rock',
      'jazz',
      'ambient',
      'testing',
    ];
  }

  @override
  Future<List<String>> fetchGenres() async {
    return const [
      'Electronic',
      'Hip-Hop',
      'Rock',
      'Pop',
      'Jazz',
      'Classical',
      'R&B / Soul',
      'Ambient',
      'Folk',
      'Metal',
      'Country',
      'Reggae',
      'Podcast',
      'Other',
    ];
  }

  @override
  Future<UploadResponseModel> uploadTrack({
    required File audioFile,
    File? artworkFile,
    required String title,
    required String artist,
    required String genre,
    String? description,
    String? caption,
    required List<String> tags,
    required bool isPublic,
    void Function(double progress)? onProgress,
  }) async {
    // Simulate upload progress in steps
    for (int i = 1; i <= 5; i++) {
      await Future.delayed(const Duration(milliseconds: 200));
      onProgress?.call(i / 5);
    }
    return UploadResponseModel(
      id: 'mock-track-${DateTime.now().millisecondsSinceEpoch}',
      status: 'processing',
    );
  }
}
