import 'dart:io';
import 'package:dio/dio.dart';
import 'package:mime/mime.dart';
import 'package:rythmify/core/network/api_client.dart';
import '../models/upload_response_model.dart';
import 'package:flutter/foundation.dart';

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
  UploadTrackRemoteDataSource({
    Dio? dio,
    Future<MultipartFile> Function(String path, DioMediaType contentType)?
    multipartFileFactory,
  }) : _dio = dio ?? apiClient.dio,
       _multipartFileFactory =
           multipartFileFactory ??
           ((path, contentType) {
             return MultipartFile.fromFile(path, contentType: contentType);
           });

  // Uses the shared ApiClient your team leader built
  // Auth token is attached automatically — you don't touch it here
  final Dio _dio;
  final Future<MultipartFile> Function(String path, DioMediaType contentType)
  _multipartFileFactory;

  // ── Fetch Tags ─────────────────────────────────────────────────────────────

  Future<List<String>> fetchTags() async {
    try {
      final response = await _dio.get('/tags');
      final data = response.data;

      debugPrint('=== TAGS RAW: $data ===');

      List<dynamic> rawList = [];
      if (data['data'] is List) {
        rawList = data['data'] as List<dynamic>; // deployed shape
      } else if (data['data'] is Map) {
        rawList = data['data']?['items'] ?? []; // old local shape
      }

      final tags = rawList
          .map((tag) {
            if (tag is String) return tag;
            if (tag is Map) return tag['name'] as String? ?? '';
            return '';
          })
          .where((t) => t.isNotEmpty)
          .toList();

      debugPrint('=== TAGS PARSED: $tags ===');
      return tags;
    } on DioException catch (e) {
      debugPrint('=== TAGS FETCH FAILED: ${e.response?.data} ===');
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
    bool isHidden = false,
    String? geoRestrictionType,
    List<String>? geoRegions,
    void Function(double progress)? onProgress,
  }) async {
    try {
      final audioMime = lookupMimeType(audioFile.path) ?? 'audio/mpeg';

      // Build fields map with EXACT names from API spec
      final Map<String, dynamic> fields = {
        'title': title,
        'artists': artist, // spec: 'artists'
        'genre': genre,
        'is_public': isPublic, // Pass as boolean
        'is_hidden': isHidden,
        'audio_file': await _multipartFileFactory(
          // spec: 'audio_file'
          audioFile.path,
          DioMediaType.parse(audioMime),
        ),
      };

      if (description != null && description.isNotEmpty) {
        fields['description'] = description;
      }

      if (geoRestrictionType != null) {
        fields['geo_restriction_type'] = geoRestrictionType;
      }

      // Cover image — spec: 'cover_image'
      if (artworkFile != null) {
        final artMime = lookupMimeType(artworkFile.path) ?? 'image/jpeg';
        fields['cover_image'] = await _multipartFileFactory(
          // spec: 'cover_image'
          artworkFile.path,
          DioMediaType.parse(artMime),
        );
      }

      final formData = FormData.fromMap(fields);

      // Tags sent as repeated fields — append [] so backend parses single items as arrays
      for (final tag in tags) {
        formData.fields.add(MapEntry('tags[]', tag));
      }

      // Geo regions sent as repeated fields — append [] so backend parses single items as arrays
      if (geoRegions != null) {
        for (final region in geoRegions) {
          formData.fields.add(MapEntry('geo_regions[]', region));
        }
      }

      debugPrint('=== SENDING TO BACKEND ===');
      debugPrint(
        'Fields: ${formData.fields.map((e) => '${e.key}=${e.value}').toList()}',
      );
      debugPrint('Files: ${formData.files.map((f) => f.key).toList()}');

      final response = await _dio.post(
        '/tracks',
        data: formData,
        options: Options(
          contentType:
              null, // Allow Dio to set multipart/form-data with boundary
          sendTimeout: const Duration(minutes: 2),
          receiveTimeout: const Duration(minutes: 2),
        ),
        onSendProgress: (sent, total) {
          if (total > 0 && onProgress != null) {
            final progress = (sent / total).clamp(0.0, 1.0);
            onProgress(progress);
          }
        },
      );

      debugPrint('=== RESPONSE ===');
      debugPrint('Status: ${response.statusCode}');
      debugPrint('Data: ${response.data}');

      return UploadResponseModel.fromJson(
        response.data as Map<String, dynamic>,
      );
    } on DioException catch (e) {
      debugPrint('=== ERROR ===');
      debugPrint('Status: ${e.response?.statusCode}');
      debugPrint('Data: ${e.response?.data}');
      throw _handleError(e);
    }
  }

  Future<List<String>> fetchGenres() async {
    try {
      final response = await _dio.get('/genres');
      final data = response.data;

      debugPrint('=== GENRES RAW: $data ===');

      List<dynamic> rawList = [];
      if (data['data'] is List) {
        rawList = data['data'] as List<dynamic>; // deployed shape
      } else if (data['data'] is Map) {
        rawList = data['data']?['items'] ?? []; // old local shape
      }

      final genres = rawList
          .map((g) => g['name'] as String? ?? '')
          .where((g) => g.isNotEmpty)
          .toList();

      debugPrint('=== GENRES PARSED: $genres ===');
      return genres;
    } on DioException catch (e) {
      debugPrint('=== GENRES FETCH FAILED: ${e.response?.data} ===');
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
