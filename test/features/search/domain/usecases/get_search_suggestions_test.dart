import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:rythmify/features/search/domain/entities/search_suggestion.dart';
import 'package:rythmify/features/search/domain/repositories/search_repository.dart';
import 'package:rythmify/features/search/domain/usecases/get_search_suggestions.dart';

class MockSearchRepository extends Mock implements SearchRepository {}

void main() {
  late GetSearchSuggestions useCase;
  late MockSearchRepository mockRepository;

  setUp(() {
    mockRepository = MockSearchRepository();
    useCase = GetSearchSuggestions(mockRepository);
  });

  setUpAll(() {
    registerFallbackValue(<SearchSuggestion>[]);
  });

  group('GetSearchSuggestions', () {
    test('returns list of SearchSuggestion from repository', () async {
      final tSuggestions = [
        const SearchSuggestion(id: '1', text: 'song one', type: 'track'),
        const SearchSuggestion(id: '2', text: 'song two', type: 'track'),
        const SearchSuggestion(id: '3', text: 'user one', type: 'user'),
      ];

      when(
        () => mockRepository.getSuggestions(any()),
      ).thenAnswer((_) async => tSuggestions);

      final result = await useCase.call('test');

      expect(result, tSuggestions);
      expect(result.length, 3);
      verify(() => mockRepository.getSuggestions('test')).called(1);
    });

    test('returns empty list when no suggestions found', () async {
      when(
        () => mockRepository.getSuggestions(any()),
      ).thenAnswer((_) async => []);

      final result = await useCase.call('xyz');

      expect(result, isEmpty);
      verify(() => mockRepository.getSuggestions('xyz')).called(1);
    });

    test('propagates exception from repository', () async {
      when(
        () => mockRepository.getSuggestions(any()),
      ).thenThrow(Exception('Network error'));

      expect(() => useCase.call('test'), throwsException);
    });

    test('passes query to repository correctly', () async {
      when(
        () => mockRepository.getSuggestions(any()),
      ).thenAnswer((_) async => []);

      await useCase.call('my search query');

      verify(() => mockRepository.getSuggestions('my search query')).called(1);
    });

    test('handles special characters in query', () async {
      when(
        () => mockRepository.getSuggestions(any()),
      ).thenAnswer((_) async => []);

      await useCase.call("test's #hashtag @mention");

      verify(
        () => mockRepository.getSuggestions("test's #hashtag @mention"),
      ).called(1);
    });

    test('handles empty query', () async {
      when(
        () => mockRepository.getSuggestions(any()),
      ).thenAnswer((_) async => []);

      await useCase.call('');

      verify(() => mockRepository.getSuggestions('')).called(1);
    });

    test('handles unicode characters in query', () async {
      when(
        () => mockRepository.getSuggestions(any()),
      ).thenAnswer((_) async => []);

      await useCase.call('日本語テスト');

      verify(() => mockRepository.getSuggestions('日本語テスト')).called(1);
    });
  });
}
