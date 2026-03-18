import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rythmify/features/messaging/data/datasources/datasource_implement.dart';
import 'package:rythmify/features/messaging/data/datasources/mock_datasource.dart';
import 'package:rythmify/features/messaging/data/repositories/repository_implement.dart';
import 'package:rythmify/features/messaging/domain/repositories/messaging_repository.dart';
import 'package:dio/dio.dart';

final repositoryprovider = Provider<MessagingRepository>((ref) {
  final dio = Dio(
    BaseOptions(
      baseUrl: 'http://localhost:8080/api/v1',
      headers: {
        'Content-Type': 'application/json',
      },
    ),
  );

  final datasource = DatasourceImplement(dio: dio);

  return RepositoryImplement(dataSource: datasource);
});