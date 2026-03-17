import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rythmify/features/messaging/data/repositories/repository_implement_mock.dart';
import 'package:rythmify/features/messaging/domain/repositories/messaging_repository.dart';

final repositoryprovider=Provider<MessagingRepository>((ref){
  return RepositoryImplementMock();
});