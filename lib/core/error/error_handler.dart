import 'package:dio/dio.dart';

class ErrorHandler {
  /// Maps an error object (likely a [DioException] or [Exception]) to a user-friendly message.
  static String getFriendlyMessage(dynamic error) {
    if (error is DioException) {
      final statusCode = error.response?.statusCode;
      final data = error.response?.data;

      // Try to extract backend message
      final serverMessage = data is Map
          ? (data['message'] ?? data['error']?['message'])
          : null;

      if (statusCode == 403) {
        // Specific case for reposting own track
        if (serverMessage?.toString().toLowerCase().contains(
              'repost your own',
            ) ??
            false) {
          return 'You cannot repost your own tracks.';
        }
        return serverMessage?.toString() ?? 'Action not allowed.';
      }

      if (statusCode == 401) {
        return 'Please log in to continue.';
      }

      if (statusCode == 404) {
        return 'Requested content not found.';
      }

      if (statusCode != null && statusCode >= 500) {
        return 'Our server is having trouble. Please try again later.';
      }

      if (error.type == DioExceptionType.connectionTimeout ||
          error.type == DioExceptionType.sendTimeout ||
          error.type == DioExceptionType.receiveTimeout ||
          error.type == DioExceptionType.connectionError) {
        return 'Connection error. Please check your internet.';
      }

      return serverMessage?.toString() ??
          'Something went wrong. Please try again.';
    }

    final errorStr = error.toString();
    if (errorStr.contains('repost your own')) {
      return 'You cannot repost your own tracks.';
    }

    return errorStr
        .replaceAll('Exception: ', '')
        .replaceAll('Exception', 'Error');
  }
}
