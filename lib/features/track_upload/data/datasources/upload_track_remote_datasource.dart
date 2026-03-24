import 'dart:io';
import 'package:dio/dio.dart';
import 'package:mime/mime.dart';
import 'package:rythmify/core/network/api_client.dart';
import '../models/upload_response_model.dart';


/// Data Source: UploadTrackRemoteDataSource
///
/// Handles all remote API operations related to track upload.
///
/// Responsibilities:
/// - Fetch available tags from backend (/tags)
/// - Upload track data and files to backend (/tracks)
/// - Build multipart/form-data requests
/// - Track upload progress
/// - Handle and map HTTP errors
///
/// Notes:
/// - Uses Dio for HTTP requests
/// - Uses MultipartFile for sending audio and image files
/// - Does NOT return domain entities, only data models

class UploadTrackRemoteDataSource {
  // Uses the shared ApiClient your team leader built
  // Auth token is attached automatically — you don't touch it here
  final Dio _dio = apiClient.dio;

  // ── Fetch Tags ─────────────────────────────────────────────────────────────

  Future<List<String>> fetchTags() async {
    try {
      final response = await _dio.get('/tags');
      final data = response.data;

      // Handle both possible response shapes from server:
      // Shape A: { "tags": ["chill", "electronic"] }
      // Shape B: { "data": { "tags": [...] } }
      final rawList = data['tags'] ?? data['data']?['tags'] ?? [];

      return (rawList as List<dynamic>)
          .map((tag) {
            if (tag is String) return tag;
            if (tag is Map) return tag['name'] as String? ?? '';
            return '';
          })
          .where((tag) => tag.isNotEmpty)
          .toList();
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // ── Upload Track ───────────────────────────────────────────────────────────

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
    try {
      final audioMime = lookupMimeType(audioFile.path) ?? 'audio/mpeg';

      // Build form fields map
      final Map<String, dynamic> fields = {
        'title': title,
        'artist': artist,
        'genre': genre,
        'is_public': isPublic.toString(),
        'audio': await MultipartFile.fromFile(
          audioFile.path,
          contentType: DioMediaType.parse(audioMime),
        ),
      };

      // Add optional fields only if they have values
      if (description != null && description.isNotEmpty) {
        fields['description'] = description;
      }
      if (caption != null && caption.isNotEmpty) {
        fields['caption'] = caption;
      }
      if (tags.isNotEmpty) {
        fields['tags'] = tags.join(',');
      }

      // Add artwork if user picked one
      if (artworkFile != null) {
        final artMime = lookupMimeType(artworkFile.path) ?? 'image/jpeg';
        fields['artwork'] = await MultipartFile.fromFile(
          artworkFile.path,
          contentType: DioMediaType.parse(artMime),
        );
      }

      final formData = FormData.fromMap(fields);

      final response = await _dio.post(
        '/tracks',
        data: formData,
        onSendProgress: (sent, total) {
          if (total > 0 && onProgress != null) {
            final progress = (sent / total).clamp(0.0, 1.0);
            onProgress(progress);
          }
        },
      );

      return UploadResponseModel.fromJson(
        response.data as Map<String, dynamic>,
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // ── Error handler ──────────────────────────────────────────────────────────

  Exception _handleError(DioException e) {
    final statusCode = e.response?.statusCode;
    final data = e.response?.data;

    // Try to extract message from server response
    final message =
        data?['error']?['message'] ??
        data?['message'] ??
        e.message ??
        'Unknown error';

    switch (statusCode) {
      case 401:
        return Exception('AUTH_401: $message');
      case 403:
        return Exception('UPLOAD_LIMIT_403: $message');
      case 413:
        return Exception('FILE_TOO_LARGE_413: $message');
      case 415:
        return Exception('UNSUPPORTED_FILE_415: $message');
      case 429:
        return Exception('RATE_LIMIT_429: $message');
      default:
        return Exception('SERVER_${statusCode ?? 'UNKNOWN'}: $message');
    }
  }
}
