import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:rythmify/features/search/domain/entities/vibes_category.dart';
import 'package:rythmify/features/search/domain/repositories/vibes_repository.dart';
import 'package:rythmify/features/search/domain/usecases/get_vibes.dart';

class MockVibesRepository extends Mock implements VibesRepository {}

void main() {
  group('GetVibes', () {
    test('returns vibes from repository', () async {
      final repository = MockVibesRepository();
      final useCase = GetVibes(repository);
      const vibes = [
        VibeCategory(
          id: 'pop',
          title: 'Pop',
          imagePath: 'assets/pop.jpg',
          height: 160,
          color: Colors.pink,
        ),
      ];
      when(() => repository.getVibes()).thenAnswer((_) async => vibes);

      final result = await useCase();

      expect(result, vibes);
      verify(() => repository.getVibes()).called(1);
    });

    test('propagates repository exception', () async {
      final repository = MockVibesRepository();
      final useCase = GetVibes(repository);
      when(() => repository.getVibes()).thenThrow(Exception('boom'));

      expect(useCase.call, throwsException);
    });
  });
}
