import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import 'package:rythmify/features/messaging/data/repositories/repository_implement.dart';
import 'package:rythmify/features/messaging/domain/repositories/messaging_repository.dart';
import 'package:rythmify/features/messaging/data/datasources/datasource_implement.dart';
import 'package:rythmify/features/messaging/data/datasources/mock_datasource.dart';

/// toggle between mock data and real API
const bool useMockData = false;

/// Provider for the [MessagingRepository] implementation.
///
/// This provider initializes the [MessagingRepository] by configuring the
/// necessary data source (either [MockDatasourceImplement] or [DatasourceImplement])
/// based on the [useMockData] flag, and sets up the HTTP client ([Dio]).
///
/// It interacts with the [Data] layer to provide a concrete repository instance
/// to the rest of the application.
final repositoryprovider = Provider<MessagingRepository>((ref) {
  final dio = Dio(
    BaseOptions(
      //baseUrl: 'http://localhost:8080/api/v1',
      baseUrl:'https://rythmify-backend-dev.livelypebble-6b7965ef.uaenorth.azurecontainerapps.io',
      headers: {'Content-Type': 'application/json'},
    ),
  );

  // Automatically switch datasources based on the boolean flag
  final datasource = useMockData
      ? MockDatasourceImplement()
      : DatasourceImplement(dio: dio);

  return RepositoryImplement(dataSource: datasource);
});
