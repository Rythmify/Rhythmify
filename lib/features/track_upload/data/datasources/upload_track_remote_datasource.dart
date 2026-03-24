// /// The ONLY file in M13 that makes HTTP calls.
// /// Throws exceptions — repository converts them to Failures.

// import 'dart:convert';
// import 'dart:io';
// import 'package:http/http.dart' as http;
// import 'package:http_parser/http_parser.dart';
// import 'package:mime/mime.dart';
// import '../../../../core/config/app_config.dart';
// import '../../../../core/config/auth_token_provider.dart';
// import '../models/upload_response_model.dart';

// class UploadTrackRemoteDataSource {
//   final AuthTokenProvider _authTokenProvider;
//   final http.Client _httpClient;

//   UploadTrackRemoteDataSource({
//     required AuthTokenProvider authTokenProvider,
//     http.Client? httpClient,
//   })  : _authTokenProvider = authTokenProvider,
//         _httpClient = httpClient ?? http.Client();

//   // ── Headers ────────────────────────────────────────────────────────

//   Future<Map<String, String>> _buildHeaders({
//     bool isMultipart = false,
//   }) async {
//     final token = await _authTokenProvider.getToken();
//     return {
//       if (!isMultipart) 'Content-Type': 'application/json',
//       'Accept': 'application/json',
//       if (token != null) 'Authorization': 'Bearer $token',
//     };
//   }

//   // ── Fetch Tags ─────────────────────────────────────────────────────

//   /// GET /tags
//   /// Returns list of tag strings e.g. ["chill", "electronic", "lofi"]
//   Future<List<String>> fetchTags() async {
//     final headers  = await _buildHeaders();
//     final uri      = Uri.parse('${AppConfig.baseUrl}/tags');
//     final response = await _httpClient
//         .get(uri, headers: headers)
//         .timeout(AppConfig.connectTimeout);

//     final json = jsonDecode(response.body) as Map<String, dynamic>;
//     _assertSuccess(response.statusCode, json);

//     // Server returns { "tags": ["chill", "electronic", ...] }
//     // Each tag might be a string or an object with id/name
//     // We extract just the name string
//     final rawTags = json['tags'] as List<dynamic>? ?? [];
//     return rawTags.map((tag) {
//       // Handle both formats:
//       // Format A: ["chill", "electronic"]     → tag is a String
//       // Format B: [{"id": 1, "name": "chill"}] → tag is a Map
//       if (tag is String) return tag;
//       if (tag is Map)    return tag['name'] as String? ?? '';
//       return '';
//     }).where((tag) => tag.isNotEmpty).toList();
//   }

//   // ── Upload Track ───────────────────────────────────────────────────

//   /// POST /tracks
//   /// Sends multipart/form-data with audio + optional artwork + metadata
//   /// Calls onProgress (0.0 → 1.0) as bytes are sent
//   Future<UploadResponseModel> uploadTrack({
//     required File audioFile,
//     File? artworkFile,
//     required String title,
//     required String artist,
//     required String genre,
//     String? description,
//     String? caption,
//     required List<String> tags,
//     required bool isPublic,
//     void Function(double progress)? onProgress,
//   }) async {
//     final headers = await _buildHeaders(isMultipart: true);
//     final uri     = Uri.parse('${AppConfig.baseUrl}/tracks');

//     final request = http.MultipartRequest('POST', uri)
//       ..headers.addAll(headers);

//     // ── Text fields ──────────────────────────────────────────────────
//     request.fields['title']       = title;
//     request.fields['artist']      = artist;
//     request.fields['genre']       = genre;
//     request.fields['is_public']   = isPublic.toString();

//     if (description != null && description.isNotEmpty) {
//       request.fields['description'] = description;
//     }
//     if (caption != null && caption.isNotEmpty) {
//       request.fields['caption'] = caption;
//     }

//     // Tags sent as comma-separated string
//     // e.g. "chill,electronic,lofi"
//     if (tags.isNotEmpty) {
//       request.fields['tags'] = tags.join(',');
//     }

//     // ── Audio file ───────────────────────────────────────────────────
//     final audioMime  = lookupMimeType(audioFile.path) ?? 'audio/mpeg';
//     final audioParts = audioMime.split('/');

//     request.files.add(await http.MultipartFile.fromPath(
//       'audio',                                    // field name server expects
//       audioFile.path,
//       contentType: MediaType(audioParts[0], audioParts[1]),
//     ));

//     // ── Artwork file (optional) ──────────────────────────────────────
//     if (artworkFile != null) {
//       final artMime  = lookupMimeType(artworkFile.path) ?? 'image/jpeg';
//       final artParts = artMime.split('/');

//       request.files.add(await http.MultipartFile.fromPath(
//         'artwork',                                // field name server expects
//         artworkFile.path,
//         contentType: MediaType(artParts[0], artParts[1]),
//       ));
//     }

//     // ── Send and track progress ──────────────────────────────────────
//     final totalBytes    = request.contentLength;
//     int sentBytes       = 0;
//     final responseBytes = <int>[];

//     final streamed = await _httpClient
//         .send(request)
//         .timeout(AppConfig.uploadTimeout);

//     await for (final chunk in streamed.stream) {
//       responseBytes.addAll(chunk);
//       sentBytes += chunk.length;

//       if (totalBytes > 0 && onProgress != null) {
//         final progress = (sentBytes / totalBytes).clamp(0.0, 1.0);
//         onProgress(progress);
//       }
//     }

//     // ── Parse response ───────────────────────────────────────────────
//     final body = utf8.decode(responseBytes);
//     final json = jsonDecode(body) as Map<String, dynamic>;

//     _assertSuccess(streamed.statusCode, json);

//     return UploadResponseModel.fromJson(json);
//   }

//   // ── Status code checker ────────────────────────────────────────────

//   void _assertSuccess(int statusCode, Map<String, dynamic> json) {
//     if (statusCode >= 200 && statusCode < 300) return; // success

//     final message = json['message'] as String? ??
//         json['error']   as String? ??
//         'Server error ($statusCode)';

//     switch (statusCode) {
//       case 401: throw _AuthException(message);
//       case 403: throw _UploadLimitException(message);
//       case 413: throw _FileTooLargeException(message);
//       case 415: throw _UnsupportedFileException(message);
//       case 429: throw _RateLimitException(message);
//       default:  throw _ServerException(message, statusCode);
//     }
//   }
// }

// // ── Private exceptions ─────────────────────────────────────────────────────
// // Stay inside this file — repository converts them to Failures

// class _AuthException          implements Exception { final String message; const _AuthException(this.message); }
// class _UploadLimitException   implements Exception { final String message; const _UploadLimitException(this.message); }
// class _FileTooLargeException  implements Exception { final String message; const _FileTooLargeException(this.message); }
// class _UnsupportedFileException implements Exception { final String message; const _UnsupportedFileException(this.message); }
// class _RateLimitException     implements Exception { final String message; const _RateLimitException(this.message); }
// class _ServerException        implements Exception { final String message; final int statusCode; const _ServerException(this.message, this.statusCode); }
