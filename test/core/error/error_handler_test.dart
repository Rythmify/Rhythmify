import 'package:flutter_test/flutter_test.dart';
import 'package:dio/dio.dart';
import 'package:rythmify/core/error/error_handler.dart';

void main() {
  group('ErrorHandler', () {
    test('returns friendly message for 401 unauthorized', () {
      final error = DioException(
        requestOptions: RequestOptions(),
        response: Response(requestOptions: RequestOptions(), statusCode: 401),
      );
      expect(
        ErrorHandler.getFriendlyMessage(error),
        'Please log in to continue.',
      );
    });

    test('returns friendly message for 403 reposting own track', () {
      final error = DioException(
        requestOptions: RequestOptions(),
        response: Response(
          requestOptions: RequestOptions(),
          statusCode: 403,
          data: {'message': 'Cannot repost your own track'},
        ),
      );
      expect(
        ErrorHandler.getFriendlyMessage(error),
        'You cannot repost your own tracks.',
      );
    });

    test('returns generic message for 500 server error', () {
      final error = DioException(
        requestOptions: RequestOptions(),
        response: Response(requestOptions: RequestOptions(), statusCode: 500),
      );
      expect(
        ErrorHandler.getFriendlyMessage(error),
        'Our server is having trouble. Please try again later.',
      );
    });

    test('returns connection error for Dio connection timeout', () {
      final error = DioException(
        requestOptions: RequestOptions(),
        type: DioExceptionType.connectionTimeout,
      );
      expect(
        ErrorHandler.getFriendlyMessage(error),
        'Connection error. Please check your internet.',
      );
    });

    test('returns friendly message for regular Exception', () {
      final error = Exception('Some weird error');
      expect(ErrorHandler.getFriendlyMessage(error), 'Some weird error');
    });
  });
}
