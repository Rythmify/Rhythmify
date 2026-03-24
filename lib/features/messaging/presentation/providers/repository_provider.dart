import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';

import 'package:rythmify/features/messaging/data/repositories/repository_implement.dart';
import 'package:rythmify/features/messaging/domain/repositories/messaging_repository.dart';

//________ Uncomment to use real data _______
//import 'package:rythmify/features/messaging/data/datasources/datasource_implement.dart';

//________ Uncomment to use mock data _______
import 'package:rythmify/features/messaging/data/datasources/mock_datasource.dart';

// Change this to switch modes
const bool useMockData = true;

final repositoryprovider = Provider<MessagingRepository>((ref) {
  final dio = Dio(
    BaseOptions(
      baseUrl: 'http://localhost:8080/api/v1',
      headers: {'Content-Type': 'application/json'},
    ),
  );

  //______ Comment and Uncomment to Switch the datasource_____
  //final datasource = DatasourceImplement(dio: dio);
  final datasource = MockDatasourceImplement();

  return RepositoryImplement(dataSource: datasource);
});
