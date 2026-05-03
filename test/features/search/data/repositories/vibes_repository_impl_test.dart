import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:rythmify/features/search/data/datasources/vibes_remote_datasource.dart';
import 'package:rythmify/features/search/data/repositories/vibes_repository_impl.dart';
import 'package:rythmify/features/search/domain/entities/vibes_category.dart';

class MockVibesRemoteSource extends Mock implements VibesRemoteSource {}

void main() {
  group('VibesRepositoryImpl', () {
    late MockVibesRemoteSource remoteSource;
    late VibesRepositoryImpl repository;

    setUp(() {
      remoteSource = MockVibesRemoteSource();
      repository = VibesRepositoryImpl(remoteSource: remoteSource);
    });

    test('delegates getVibes to remote source', () async {
      const vibes = [
        VibeCategory(
          id: 'rock',
          title: 'Rock',
          imagePath: 'assets/rock.jpg',
          height: 120,
          color: Color(0xFF000000),
        ),
      ];
      when(() => remoteSource.getVibes()).thenAnswer((_) async => vibes);

      final result = await repository.getVibes();

      expect(result, vibes);
      verify(() => remoteSource.getVibes()).called(1);
    });

    test('propagates remote source exception', () async {
      when(() => remoteSource.getVibes()).thenThrow(Exception('boom'));

      expect(repository.getVibes, throwsException);
    });
  });
}
