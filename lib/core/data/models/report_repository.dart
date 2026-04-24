import 'package:dio/dio.dart';
import '../../data/models/report_request.dart';

class ReportRepository {
  final Dio dio;

  ReportRepository(this.dio);

  Future<void> submitReport(ReportRequest request) async {
    try {
      final response = await dio.post(
        '/reports',
        data: request.toJson(),
      );

      if (response.statusCode != 201) {
        throw Exception('Unexpected response from server');
      }
    } catch (e) {
  if (e is DioException) {
    print('STATUS: ${e.response?.statusCode}');
    print('DATA: ${e.response?.data}');
  }

  throw Exception('Something went wrong.');

    }
  }
}