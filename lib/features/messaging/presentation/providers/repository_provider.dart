import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rythmify/core/network/api_client.dart';

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
/// based on the [useMockData] flag, and utilizes the centralized [ApiClient].
final repositoryprovider = Provider<MessagingRepository>((ref) {
  // Automatically switch datasources based on the boolean flag.
  // We pass the global apiClient.dio instance which already has the
  // base URL, timeouts, logging, and token interceptors configured.
  final datasource = useMockData
      ? MockDatasourceImplement()
      : DatasourceImplement(dio: apiClient.dio);

  return RepositoryImplement(dataSource: datasource);
});
