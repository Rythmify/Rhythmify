import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rythmify/features/messaging/data/datasources/datasource_implement.dart';
import 'package:rythmify/features/messaging/data/datasources/mock_datasource.dart';
import 'package:rythmify/features/messaging/data/repositories/repository_implement.dart';
import 'package:rythmify/features/messaging/domain/repositories/messaging_repository.dart';
import 'package:dio/dio.dart';

final repositoryprovider = Provider<MessagingRepository>((ref) {
  final dio = Dio();
  final datasource = DatasourceImplement(dio:dio);

  //final datasource = MockDatasourceImplement();

  return RepositoryImplement(
    dataSource: datasource,
  );
});